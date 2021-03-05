// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss"


// import jQuery from 'jquery';
// window.jQuery = window.$ = jQuery; // Bootstrap requires a global "$" object.
import "bootstrap";
// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
// import "../node_modules/jquery/dist/jquery.min.js";
// import "../node_modules/moment/min/moment.min.js";
// import "../node_modules/daterangepicker/daterangepicker.js";
import "jquery";
import "moment";





import "phoenix_html"
