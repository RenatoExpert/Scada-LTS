import commonjs from '@rollup/plugin-commonjs';
import resolve from '@rollup/plugin-node-resolve';

// rollup.config.js
const config = {
  input: 'index.js',
  output: {
    file: 'dist/hp.umd.js',
    format: 'umd',
    name: 'hp-scada',
  },
	plugins: [commonjs(), resolve({ browser:true })]
};

export default config;
