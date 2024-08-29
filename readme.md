<!-- replace with your own-->
# Syncify/Dawn Example

This repo aims to provide an opinionated guide to using [Shopify/dawn](https://github.com/shopify/dawn) with [Syncify](https://github.com/panoply/syncify/tree/rc1). Additionally, I'll be showing off my current (08/2024) workflow.

## Why this is needed ##

### Background ###

A friend has asked me to make a couple of code changes on her Shopify website. Because she is new to the e-commerce game, she hasn't yet invested into her theme (tsk tsk, i know). She has asked for a feature to be built into her theme, nothing too difficult. However, she's using the Dawn theme, because it gets the job done for her needs. 

### The Problem ###

Syncify doesn't support legacy javascript very well as it expects you to covert your scripts to modern practices. This however presents a problem when using Shopify's Dawn theme, as Shopify's javascript techniques do not play nicely with Syncify. During Syncify's build process, these scripts are transformed using [esbuild](https://esbuild.github.io/) and by the end of the build, the javascript output is a jumbled mess. As such, the theme will now spit out errors in the browser for almost every script.

Syncify recommends that we whip these javascript files into shape, but who's got time for that. I just want to make a few quick changes on my friends theme, not rewrite javascript just to get the same result on the live theme.

Syncify offers ways to intercept the esbuild config, and this somewhat works. When in the dev environment, we can hot reload the script and provided this script doesn't call functions from other (broken) scripts, everything is good. However, once you build a production version of the theme, well esbuild is going to optimize the files and break everything again. 

See the problem with the `minify: true` or `--minify` parameter, it actually does 3 actions.

> This option does three separate things in combination: it removes whitespace, it rewrites your syntax to be more compact, and it renames local variables to be shorter. Usually you want to do all of these things, but these options can also be enabled individually if necessary
[esbuild documentation](https://esbuild.github.io/api/#minify)

These 3 functions are fine in normal circumstances, but in our case. When removing the local variables, we're breaking the cross-script functions that Shopify uses for the Dawn theme.

### The Solution ###

Given we know the problem now, the solution is simple, ensure `minifyIdentifiers: false` or `--minifyIdentifiers:false` is set for our build process. We still want to enable the other options, but this particular option is what is messing with our code. So let's fix that.

## Installation ##

1. Use the [WolfGreyDev/syncify-skeleton](https://github.com/WolfGreyDev/syncify-skeleton) template to create a new developer environment repository. Follow the instructions on how to install.

    > When creating a new repo, be sure to name it in a way you can differentiate it as the development environment. eg 'syncify-dawn-example-dev'

    > Following the instructions on the skeleton repo will test if your connection is working with your store.

### Notes
- I use the VSCode extension [Liquid](https://marketplace.visualstudio.com/items?itemName=sissel.shopify-liquid) and **you should too**. This repo is already set up for your project auto-completions and basic formatting (which you can change). You can customize these settings in the `.liquidrc` file.
- If you're still having issues, head over to the [Shopify Developers Discord](https://discord.gg/bU3P5TPE) where we have a dedicated channel for Syncify stuff. **Don't be dumb! Complete the application form properly otherwise you'll be banned instantly.**

## Contributing

This repo isn't intended to be contributed to. As updates happen to Syncify this repo will be updated appropriately however, Syncify will eventually make this repo obsolete.

## Credits

- [ΝΙΚΟΛΑΣ / Sissel](https://github.com/panoply)
- [Shopify Developer Discord](https://discord.gg/bU3P5TPE)

## License

The MIT License (MIT). Please see [License File](license.md) for more information.
<!--/replace with your own-->