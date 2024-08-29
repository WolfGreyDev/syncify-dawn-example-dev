<!-- replace with your own-->
# Syncify/Dawn Example

This repo aims to provide an opinionated guide to using [Shopify/dawn](https://github.com/shopify/dawn) with [Syncify](https://github.com/panoply/syncify/tree/rc1). Additionally, I'll be showing off my current (08/2024) workflow.

## Why this is needed

### Background

A friend has asked me to make a couple of code changes on her Shopify website. Because she is new to the e-commerce game, she hasn't yet invested into her theme (tsk tsk, i know). She has asked for a feature to be built into her theme, nothing too difficult. However, she's using the Dawn theme, because it gets the job done for her needs. 

### The Problem

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

    > [!NOTE]
    > When creating a new repo, be sure to name it in a way you can differentiate it as the development environment. eg 'syncify-dawn-example-dev'

    > [!IMPORTANT]
    > Following the instructions on the skeleton repo will test if your connection is working with your store.

2. Empty the templates path from your `package.json`.

    ```json
        "templates": "template/*" -> "templates": ""
    ```

3. Fork the [Shopify/dawn](https://github.com/Shopify/dawn) repo.

    > [!NOTE]
    > This will handle any updates to dawn without interfering with your project/s source code via the sync fork function.

4. Create another repo for your source code using the dawn fork as a template:
    
    1. In your dawn fork settings, tick the option to make this repo a 'template repository'. 
    
    2. Go back and click the 'use this template' button in the top right of your repository. Create a new repository.

        > [!NOTE]
        > Be sure to name this repo in a way to differentiate it as your source code. eg 'syncify-dawn-example-source'

        > [!TIP]
        > Disable both CI and Contributor License Agreement actions in the actions tab in your new repository.

5. Replace the existing dusk source with the new source repo you just created

    1. Delete the source folder from your development environment.

    2. You must commit the source removal to your development environment.

        > [!CAUTION]
        > Failure to do this will mess your development environment up! It's easier to start again than deal with undoing this. In my experience.

    3. Using GitHub submodules, add the source back to the development environment.

        `git submodule add 'your-repo' 'source-folder'`

        eg. `git submodule add git@github.com:WolfGreyDev/syncify-dawn-example-source.git source`

        > [!TIP]
        > If you're new to submodules, check out this [blog post](https://github.blog/open-source/git/working-with-submodules/) to get an understanding of what they are. Essentially a repo inside a repo.

    4. Be sure to commit the submodule addition in your development git.

        > [!WARNING]
        > You'll want to make sure that when a commit happens inside your submodule, you also commit the change in your development environment. That way if something goes wrong, when you go back, your submodule will go back to the equivalent commit.

        > [!TIP]
        > Though most of the time you can make a quick change back without needing to play with the commit history. (Preferred)

6. Add our own esbuild config which allows production builds to not minify the syncify way.
        
    1. We need to add `esbuild` to our dev dependencies again.

        `pnpm add esbuild -D`

    2. Create a new file in your base directory called `esbuild.mjs`

    3. Add the following code to the new file.

        ```js
        import * as esbuild from 'esbuild'

        await esbuild.build({
            entryPoints: [
                "./source/assets/*.js"
            ],
            outdir: './theme/assets',
            bundle: false,
            format: 'esm',
            treeShaking: false,
            minify: false,
            minifyWhitespace: true,
            minifySyntax: true,
            minifyIdentifiers: false,
            sourcemap: false
        })
        ```

    4. Change the `pnpm build` script in our `package.json`.

        ```json
        "build": "syncify --build --prod --clean; node esbuild.mjs"
        ```

        > [!NOTE]
        > The way this works is, Syncify will run a complete production build first, including the messed up minified scripts. But immediately after, we overwrite with our legacy code safe esbuild config.

        > [!IMPORTANT]
        > Yes we a building our scripts twice. Yes it's dumb. But if dawn can exist, then this can exist. Plus it comes at very little performance cost.

        > [!NOTE]
        > You may think why not remove the scripts from the paths and only build once. If we did that, we wouldn't be able to run `pnpm dev` and have our changes pushed to the theme folder.
    
7. Run `pnpm build` for a production build of dawn.

8. Run `pnpm upload` to push the theme folder to your development theme.

    > [!WARNING]
    > WE DO NOT PUSH TO ANY LIVE THEME WITHOUT TESTING FIRST!

9. In the `.liquidrc` file, you should add the `source` directory to a new `ingnore` option under `format`.

    ```json
    "format": {
        "ignore": [
            "./source/**/*"
        ],
        ...
    }
    ```

    > [!WARNING]
    > If you do not do this and allow æsthetic to style your code, it's going to make it harder down the road to perform updates with the fork.

    > [!TIP]
    > Consider just adopting the dawn styling for these projects, we've come this far, a little more pain won't hurt... much

10. Manually copy the `settings_data.json` contents from `/source/config/` and paste it into the development theme on the store via the Shopify code editor.

    > [!NOTE]
    > You'll see a warning when using the theme editor that there is a problem with the settings_data.json file as it can't find some references.

11. Don't forget to commit these changes to your development environment.

**And That's It! (well sort of)**

## Bonus Time!

Coming next commit!

## Design Considerations

- I have intentionally left the `settings_data.json` out of my paths in my `package.json`.

    When I'm developing, the changes I make in the settings, I want to persist on the store when I do a new upload. If I were to upload a blank settings file or even the dawn default settings every time I do an upload, it makes testing new features extremely tedious.

- I have removed the `templates` value from my `package.json`.

    Again this is a choice I make to ensure I don't upload an empty template and remove any settings I may have applied previously.

    This is a double edged sword though, as I cannot easily push new templates to the theme.  To combat this, since I create new templates rarely, I just manually create the template in the theme editor.

    When we did our first upload, we uploaded all the essential templates to get started so adding to them is very simple.

- Why did I choose to put my source in it's own repo

    Two reasons really.

    1. I like to keep my source changes isolated and not tied to my development environment (or as little as possible).

    2. Updating from a parent/template repo is easier via GitHub, or if I have errors, I can fix the errors in a separate project. Updating a submodule is as easy as pulling in the changes.

- Why use esbuild again if it didn't do what I wanted in the first place.

    Really, after spending a day and a half diving into esbuild to understand why it's used, I felt it was a better option out of the inbuilt options.

    I've tried a webpack approach where I'd copy the files and then ran a plugin to minimize it. Yeah it worked, but it felt clunky and detached from the build process.

    Even though the esbuild implementation is a separate instance of esbuild running right after Syncify's instance, it is virtually instant. This makes me *feel* like it's apart of the package.

    Is the actual implementation jank? Absolutely. But it works and does what I need it to do. It doesn't produce as optimal scripts as a completely minified script, but it gets close enough without complaining.

- Well what about code for production themes?

    Stay tuned I guess. Next commit will have the answer.

## Conclusion

We've now set up Syncify, with all that juicy Syncify features, with Shopify's Dawn theme. I can now go start to make changes to our source code and know that when I build, it'll work (unless I screw something up).

**BUT what happens when when Shopify update the dawn repo?**

Since we've make a fork of the theme, we can simply sync the fork and pull in the new changes. However, we then have the issue of syncing our fork with the source repo we're using here. And this is slightly more difficult.

Using GitHub actions, specifically [actions-template-sync](https://github.com/marketplace/actions/actions-template-sync), it gives us a way to sync our two repos by creating a pull request to our source with the changes.

> [!CAUTION]
> I have yet to get this working as I'm extremely unfamiliar with GitHub actions and seem to run into permission errors. However, I'm assured this is the way and simple to set up. Once I have a working template and instructions, I'll update this repo.

> [!NOTE]
> I'd welcome any guidance to setting this up properly.

## Notes
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