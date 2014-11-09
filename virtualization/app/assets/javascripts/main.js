/* 
* @Author: Beinan
* @Date:   2014-11-09 16:17:40
* @Last Modified by:   Beinan
* @Last Modified time: 2014-11-09 16:29:19
*/

require.config({
  paths: {
    'd3' : 'libs/d3',
    'raphael': 'libs/raphael'
  },
  shim: {
    d3: {
      exports: 'd3'
    }
  }
});


require(["d3", "raphael"],function(d3, raphael) {
   
});