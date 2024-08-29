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