## Licensed to Cloudera, Inc. under one
## or more contributor license agreements.  See the NOTICE file
## distributed with this work for additional information
## regarding copyright ownership.  Cloudera, Inc. licenses this file
## to you under the Apache License, Version 2.0 (the
## "License"); you may not use this file except in compliance
## with the License.  You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
<%!
from desktop import conf
from desktop.lib.i18n import smart_unicode
from django.utils.translation import ugettext as _

home_url = url('desktop.views.home')
from desktop.conf import USE_NEW_EDITOR
if USE_NEW_EDITOR.get():
  home_url = url('desktop.views.home2')
%>
<!DOCTYPE html>
<%def name="is_selected(selected)">
  %if selected:
    class="active"
  %endif
</%def>
<%def name="get_nice_name(app, section)">
  % if app and section == app.display_name:
    - ${app.nice_name}
  % endif
</%def>
<%def name="get_title(title)">
  % if title:
    ${smart_unicode(title).upper()}
  % endif
</%def>
<html lang="en">
<head>
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta charset="utf-8">
  <title>Hue ${get_nice_name(current_app, section)} - ${get_title(title)}</title>
  <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=0"/>
  <link rel="icon" type="image/x-icon" href="${ static('desktop/art/favicon.ico') }" />
  <meta name="description" content="">
  <meta name="author" content="">

  <link href="${ static('desktop/css/roboto.css') }" rel="stylesheet">
  <link href="${ static('desktop/ext/css/bootplus.css') }" rel="stylesheet">
  <link href="${ static('desktop/ext/css/bootplus-responsive.css') }" rel="stylesheet">
  <link href="${ static('desktop/ext/css/font-awesome.min.css') }" rel="stylesheet">
  <link href="${ static('desktop/css/hue-mobile.css') }" rel="stylesheet">

  <style type="text/css">
    body {
      display: none;
      visibility: hidden;
    }
  </style>

  <script type="text/javascript" charset="utf-8">

    var LOGGED_USERNAME = '${ user.username }';
    var IS_S3_ENABLED = '${ is_s3_enabled }' === 'True';

    // jHue plugins global configuration
    jHueFileChooserGlobals = {
      labels: {
        BACK: "${_('Back')}",
        SELECT_FOLDER: "${_('Select this folder')}",
        CREATE_FOLDER: "${_('Create folder')}",
        FOLDER_NAME: "${_('Folder name')}",
        CANCEL: "${_('Cancel')}",
        FILE_NOT_FOUND: "${_('The file has not been found')}",
        UPLOAD_FILE: "${_('Upload a file')}",
        FAILED: "${_('Failed')}"
      },
      user: "${ user.username }"
    };

    jHueHdfsTreeGlobals = {
      labels: {
        CREATE_FOLDER: "${_('Create folder')}",
        FOLDER_NAME: "${_('Folder name')}",
        CANCEL: "${_('Cancel')}"
      }
    };

    jHueTableExtenderGlobals = {
      labels: {
        GO_TO_COLUMN: "${_('Go to column:')}",
        PLACEHOLDER: "${_('column name...')}",
        LOCK: "${_('Click to lock this row')}",
        UNLOCK: "${_('Click to unlock this row')}"
      }
    };

    jHueTourGlobals = {
      labels: {
        AVAILABLE_TOURS: "${_('Available tours')}",
        NO_AVAILABLE_TOURS: "${_('None for this page.')}",
        MORE_INFO: "${_('Read more about it...')}",
        TOOLTIP_TITLE: "${_('Demo tutorials')}"
      }
    };

    LeafletGlobals = {
      layer: '${ leaflet['layer'] |n,unicode }',
      attribution: '${ leaflet['attribution'] |n,unicode }'
    };

    ApiHelperGlobals = {
      i18n: {
        errorLoadingDatabases: '${ _('There was a problem loading the databases') }',
        errorLoadingTablePreview: '${ _('There was a problem loading the preview') }'
      },
      user: '${ user.username }'
    }
  </script>

  <!--[if lt IE 9]>
  <script type="text/javascript">
    if (document.documentMode && document.documentMode < 9){
      location.href = "${ url('desktop.views.unsupported') }";
    }
  </script>
  <![endif]-->

  <script type="text/javascript">
    // check if it's a Firefox < 7
    var _UA = navigator.userAgent.toLowerCase();
    for (var i = 1; i < 7; i++) {
      if (_UA.indexOf("firefox/" + i + ".") > -1) {
        location.href = "${ url('desktop.views.unsupported') }";
      }
    }

    // check for IE document modes
    if (document.documentMode && document.documentMode < 9){
      location.href = "${ url('desktop.views.unsupported') }";
    }
  </script>

  <script src="${ static('desktop/js/hue.utils.js') }"></script>
  <script src="${ static('desktop/ext/js/jquery/jquery-2.1.1.min.js') }"></script>
  <script src="${ static('desktop/js/jquery.migration.js') }"></script>
  <script src="${ static('desktop/ext/js/jquery/plugins/jquery.cookie.js') }"></script>
  <script src="${ static('desktop/ext/js/jquery/plugins/jquery.total-storage.min.js') }"></script>
  <script src="${ static('desktop/ext/js/jquery/plugins/jquery.touchSwipe.min.js') }"></script>
  <script src="${ static('desktop/ext/js/bootstrap.min.js') }"></script>
  <script src="${ static('desktop/ext/js/bootstrap-better-typeahead.min.js') }"></script>
  <script src="${ static('desktop/ext/js/moment-with-locales.min.js') }" type="text/javascript" charset="utf-8"></script>

  <script type="text/javascript" charset="utf-8">

    moment.locale(window.navigator.userLanguage || window.navigator.language);
    localeFormat = function (time) {
      var mTime = time;
      if (typeof ko !== 'undefined' && ko.isObservable(time)) {
        mTime = time();
      }
      if (moment(mTime).isValid()) {
        return moment.utc(mTime).format("L LT");
      }
      return mTime;
    }

    //Add CSRF Token to all XHR Requests
    var xrhsend = XMLHttpRequest.prototype.send;
    XMLHttpRequest.prototype.send = function (data) {
    %if request and request.COOKIES and request.COOKIES.get('csrftoken','')!='':
      this.setRequestHeader('X-CSRFToken', "${request.COOKIES.get('csrftoken')}");
    %else:
      this.setRequestHeader('X-CSRFToken', "");
    %endif

      return xrhsend.apply(this, arguments);
    }

    // sets global apiHelper TTL
    $.totalStorage('hue.cacheable.ttl', ${conf.CUSTOM.CACHEABLE_TTL.get()});

    var IDLE_SESSION_TIMEOUT = -1;

    $(document).ready(function () {
      // forces IE's ajax calls not to cache
      if ($.browser.msie) {
        $.ajaxSetup({ cache: false });
      }

      // prevents framebusting and clickjacking
      if (self == top){
        $("body").css({
          'display': 'block',
          'visibility': 'visible'
        });
      }
      else {
        top.location = self.location;
      }

      %if conf.AUTH.IDLE_SESSION_TIMEOUT.get() > -1 and not skip_idle_timeout:
      IDLE_SESSION_TIMEOUT = ${conf.AUTH.IDLE_SESSION_TIMEOUT.get()};
      var idleTimer;
      function resetIdleTimer() {
        clearTimeout(idleTimer);
        idleTimer = setTimeout(function () {
          // Check if logged out
          $.get('/desktop/debug/is_idle');
        }, (IDLE_SESSION_TIMEOUT * 1000) + 1000);
      }

      $(document).on('mousemove', resetIdleTimer);
      $(document).on('keydown', resetIdleTimer);
      $(document).on('click', resetIdleTimer);
      resetIdleTimer();
      %endif

      % if 'jobbrowser' in apps:
      var JB_CHECK_INTERVAL_IN_MILLIS = 30000;
      var checkJobBrowserStatusIdx = window.setTimeout(checkJobBrowserStatus, 10);

      function checkJobBrowserStatus(){
        $.post("/jobbrowser/jobs/", {
            "format": "json",
            "state": "running",
            "user": "${user.username}"
          },
          function(data) {
            if (data != null && data.jobs != null) {
              huePubSub.publish('jobbrowser.data', data.jobs);
              if (data.jobs.length > 0){
                $("#jobBrowserCount").removeClass("hide").text(data.jobs.length);
              }
              else {
                $("#jobBrowserCount").addClass("hide");
              }
            }
          checkJobBrowserStatusIdx = window.setTimeout(checkJobBrowserStatus, JB_CHECK_INTERVAL_IN_MILLIS);
        }).fail(function () {
          window.clearTimeout(checkJobBrowserStatusIdx);
        });
      }
      huePubSub.subscribe('check.job.browser', checkJobBrowserStatus);
      % endif

      window.hueDebug = {
        viewModel: function () {
          return ko.dataFor(document.body);
        }
      }
    });
  </script>
</head>
<body>

<%
  def count_apps(apps, app_list):
    count = 0
    found_app = ""
    for app in app_list:
      if app in apps:
       found_app = app
       count += 1
    return found_app, count
%>
<div class="navbar navbar-fixed-top">
  <div class="navbar-inner">
    <div class="container">
      <button type="button" class="btn btn-navbar" data-toggle="collapse" data-target=".nav-collapse">
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
      </button>
      <a class="brand" href="#">
        <img src="${ static('desktop/art/hue-logo-mini-white.png') }" />
        ${get_title(title)}
      </a>
      <div class="nav-collapse collapse">
        <ul class="nav">
          <li><a title="${_('Assist')}" rel="navigator-tooltip" href="${ url('desktop.views.assist_m') }">${_('Assist')}</a></li>
          % if 'beeswax' in apps:
             % if USE_NEW_EDITOR.get():
             <li><a href="${ url('notebook:editor_m') }?type=hive">${_('Hive')}</a></li>
             % endif
           % endif
           % if 'impala' in apps:
             % if USE_NEW_EDITOR.get(): ## impala requires beeswax anyway
             <li><a href="${ url('notebook:editor_m') }?type=impala">${_('Impala')}</a></li>
             % endif
           % endif
           % if 'search' in apps:
             <li><a href="${ url('search:index_m') }">${_('Search')}</a></li>
           % endif
          <li><a title="${_('Sign out')}" href="/accounts/logout/">${_('Sign out')}</a></li>
        </ul>
      </div>
    </div>
  </div>
</div>

