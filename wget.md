wget Snippets
=============

## Mirror a Website

This will mirror a website with assets from various CDN servers:

```bash
wget --mirror –w 2 –p –-convert-links –P -Dstatic.example.com,static1.example.com,media.example.com,cdn.example.com -H ./target_dir http://www.example.com/
```
