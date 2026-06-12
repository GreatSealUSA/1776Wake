import os
import re
import requests
from pathlib import Path
from lxml import etree
from tqdm import tqdm 

#
# Re:Joyce Podcast Downloader
# Downloads all episodes in chronological order to a folder of your choice.
# inspired by:
#  https://old.reddit.com/r/jamesjoyce/comments/1u2g2bw/re_joyce_podcast_update/oqxl15f/
#
# License: Public Domain. No rights reserved.
#

FEED_URL = "https://rss.libsyn.com/shows/618765/destinations/5397235.xml"
OUT_DIR = Path("./ReJoyceLocal")


def sanitize_filename(text: str) -> str:
    """Removes punctuation and replaces spaces with underscores."""
    clean = re.sub(r"[^\w\s-]", "", text)
    clean = re.sub(r"\s+", "_", clean.strip())
    return clean


def main():
    print("Fetching RSS feed...")
    try:
        response = requests.get(FEED_URL, timeout=30)
        response.raise_for_status()
    except requests.RequestException as e:
        print(f"Failed to fetch RSS feed: {e}")
        return

    # Use lxml with recovery mode enabled to bypass malformed XML tokens
    parser = etree.XMLParser(recover=True, encoding="utf-8")
    try:
        root = etree.fromstring(response.content, parser=parser)
    except Exception as e:
        print(f"Parsing failed despite recovery mode: {e}")
        return

    # Gather items and sort oldest first
    items = root.xpath(".//item")
    items.reverse()
    total_items = len(items)

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    print(f"Found {total_items} episodes. Starting sync to: {OUT_DIR}\n")

    for idx, item in enumerate(items, start=1):
        title_el = item.find("title")
        title = title_el.text if title_el is not None else "Untitled"

        enclosure = item.find("enclosure")
        if enclosure is None or "url" not in enclosure.attrib:
            print(f"[{idx}/{total_items}] Skipping (no audio): {title}")
            continue

        url = enclosure.attrib["url"]

        # Parse file extension from url query parameters
        url_path = url.split("?")[0]
        ext = os.path.splitext(url_path)[1].lstrip(".")
        if not ext:
            ext = "mp3"

        safe_title = sanitize_filename(title)
        filename = f"{idx:03d}_{safe_title}.{ext}"
        dest_path = OUT_DIR / filename

        # Check if episode is already fully downloaded
        if not dest_path.exists():
            print(f"[{idx}/{total_items}] Downloading: {title}")
            try:
                with requests.get(url, stream=True, timeout=60) as r:
                    r.raise_for_status()
                    
                    # Track file size from server headers for progress calculation
                    total_size = int(r.headers.get("content-length", 0))
                    
                    # Initialize tqdm progress bar
                    with tqdm(
                        total=total_size, 
                        unit="B", 
                        unit_scale=True, 
                        desc="Progress",
                        leave=True
                    ) as pbar:
                        with open(dest_path, "wb") as f:
                            for chunk in r.iter_content(chunk_size=8192):
                                if chunk:
                                    f.write(chunk)
                                    pbar.update(len(chunk))
                                    
            except requests.RequestException as e:
                print(f" ❌ Failed to download {title}: {e}")
                # Remove partial file if download failed midway
                if dest_path.exists():
                    dest_path.unlink()
        else:
            print(f"[{idx}/{total_items}] Skipping (exists): {title}")

    print("\n🎉 Done! All episodes processed.")


if __name__ == "__main__":
    main()

