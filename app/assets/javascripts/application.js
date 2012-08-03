// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
// jna note: Order here is very important, do not use require_tree, it's worthless.
//
//= require jquery-1.7.2.min.js
//= require jquery-ui-1.8.21.custom.min.js
//= require jquery.ui.widget.js
//= require jquery-ui-timepicker-addon.js
//= require tmpl.min.js
//= require load-image.min.js
//= require canvas-to-blob.min.js
//= require bootstrap.min.js
//= require bootstrap-image-gallery.min.js
//= require jquery.iframe-transport.js
//= require jquery.fileupload.js
//= require jquery.fileupload-fp.js
//= require jquery.fileupload-ui.js
//= require jquery.fancybox.js
//= require jquery.fancybox.pack.js
//= require jquery.form.js
//= require jquery.mousewheel-3.0.6.pack.js
//= require locale.js
//= require main.js
//= require jquery_ujs
//= require jquery.dataTables.min.js
//= require jquery.dataTables.rowReordering.js
//= require TableTools.min.js
//= require DT_bootstrap.js

// extend datatables with reload
// can put these on settimer later on if need be.
$.fn.dataTableExt.oApi.fnReloadAjax = function ( oSettings, sNewSource, fnCallback, bStandingRedraw )
{
  if ( typeof sNewSource != 'undefined' && sNewSource != null )
    {
      oSettings.sAjaxSource = sNewSource;
    }
  this.oApi._fnProcessingDisplay( oSettings, true );
  var that = this;
  var iStart = oSettings._iDisplayStart;
  var aData = [];
  
  this.oApi._fnServerParams( oSettings, aData );
  
  oSettings.fnServerData( oSettings.sAjaxSource, aData, function(json) {
      /* Clear the old information from the table */
      that.oApi._fnClearTable( oSettings );
      
      /* Got the data - add it to the table */
      var aData =  (oSettings.sAjaxDataProp !== "") ?
        that.oApi._fnGetObjectDataFn( oSettings.sAjaxDataProp )( json ) : json;
      
      for ( var i=0 ; i<aData.length ; i++ )
        {
          that.oApi._fnAddData( oSettings, aData[i] );
        }
      
      oSettings.aiDisplay = oSettings.aiDisplayMaster.slice();
      that.fnDraw();
      
      if ( typeof bStandingRedraw != 'undefined' && bStandingRedraw === true )
        {
          oSettings._iDisplayStart = iStart;
          that.fnDraw( false );
        }
      
      that.oApi._fnProcessingDisplay( oSettings, false );
      
      /* Callback user function - for event handlers etc */
      if ( typeof fnCallback == 'function' && fnCallback != null )
        {
          fnCallback( oSettings );
        }
    }, oSettings );
};
