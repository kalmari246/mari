<h1 align="center"><code>mari</code></h1>

A Gentoo overlay. [Clyde](https://support.discord.com/hc/en-us/articles/13066317497239-Clyde-Discord-s-AI-Chatbot) has written most of this overlay.

### Install

Enable as usual:

```bash
eselect repository add mari git https://github.com/kalmari246/mari.git
```

### Contents

- `media-libs/mesa vulkan VIDEO_CARDS: nouveau`: Enables NVK. Be aware it is still in development. Performance is ~10% of NVIDIA drivers as of 15th November 2023.
