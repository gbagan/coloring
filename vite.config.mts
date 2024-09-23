import { defineConfig } from 'vite';
import solidPlugin from 'vite-plugin-solid';
import Unocss from 'unocss/vite';

export default defineConfig({
  base: "./",
  plugins: [
    Unocss({
      rules: [
        ['graphtext', {font: 'bold 12px sans-serif', fill: 'black'} ]
      ],
      shortcuts: {
        btn: "px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-200 hover:bg-gray-100 hover:text-blue-700 focus:z-10 focus:ring-2 focus:ring-blue-700 focus:text-blue-700",
        btngroup: "inline-flex rounded-md shadow-sm",
        select: "bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5",
        textarea: "block p-2.5 w-full text-sm text-gray-900 bg-gray-50 rounded-lg border border-gray-300 focus:ring-blue-500 focus:border-blue-500",
        textinput: "bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5",
        configtitle: "mb-2 mt-4 text-2xl font-bold",
        dialog: "bg-white rounded-lg shadow backdrop:bg-gray backdrop:bg-op-70",
        dialogtitle: "p-4 min-h-8 border-b-2 text-4xl font-medium",
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
