import { defineConfig } from 'vite';
import solidPlugin from 'vite-plugin-solid';
import Unocss from 'unocss/vite';

export default defineConfig({
  base: "./",
  plugins: [
    Unocss({
      rules: [
        ['w-42vw', { width: '42vw' }],
        ['graphtext', {font: 'bold 6px sans-serif', fill: 'black'} ]
      ],
      shortcuts: {
        btn: "px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-200 hover:bg-gray-100 hover:text-blue-700 focus:z-10 focus:ring-2 focus:ring-blue-700 focus:text-blue-700",
        select: "bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5",
      }
    }),
    solidPlugin(),
  ],
  build: {
    target: 'esnext',
  },
  server: {
    port: 3000,
  },
});
