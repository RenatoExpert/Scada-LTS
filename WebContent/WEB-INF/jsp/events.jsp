<%--
    Mango - Open Source M2M - http://mango.serotoninsoftware.com
    Copyright (C) 2006-2011 Serotonin Software Technologies Inc.
    @author Matthew Lohbihler
    
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see http://www.gnu.org/licenses/.
--%>
<%@ include file="/WEB-INF/jsp/include/tech.jsp" %>
<%@page import="com.serotonin.mango.vo.UserComment"%>
<%@page import="com.serotonin.mango.rt.event.type.EventType"%>
<%@page import="com.serotonin.mango.web.dwr.EventsDwr"%>
<tag:page dwr="EventsDwr">
  <%@ include file="/WEB-INF/jsp/include/userComment.jsp" %>
  <link rel="stylesheet" href="resources/jquery.ui.all.css">
  <link rel="stylesheet" href="resources/demos.css">
  <script type="text/javascript" src="resources/jquery.js"></script>
  <script type="text/javascript" src="resources/jquery_ui.js"></script>
  <script type="text/javascript" src="resources/jquery.ui.datepicker.js"></script>
  <script type="text/javascript" src="resources/jquery.ui.datepicker-pt-BR.js"></script>
  <style>
    .incrementControl {
      width: 2em;
    }
  </style>
  <script type="text/javascript">
    // Tell the log poll that we're interested in monitoring pending alarms.
    mango.longPoll.pollRequest.pendingAlarms = true;
    // dojo.requireLocalization("dojo.i18n.calendar", "gregorian", null, "de,en,es,fi,fr,ROOT,hu,it,ja,ko,nl,pt,pt-br,sv,zh,zh-cn,zh-hk,zh-tw");
    // dojo.requireLocalization("dojo.i18n.calendar", "gregorianExtras", null, "ROOT,ja,zh");

    jQuery.noConflict();

    jQuery.datepicker.setDefaults(jQuery.datepicker.regional['pt-BR']);

    jQuery(function() {
      jQuery('#datePicker').datepicker();
    });

    function updatePendingAlarmsContent(content) {
      hide("hourglass");

      $set("pendingAlarms", content);
      if (content) {
        show("ackAllDiv");
        hide("noAlarms");
      } else {
        $set("pendingAlarms", "");
        hide("ackAllDiv");
        show("noAlarms");
      }
    }

    function doSearchOld() {
      setDisabled("searchBtn", true);
      $set("searchMessage", "<fmt:message key='events.search.searching'/>");
      var eventId = parseInt($get("eventId"));
      var maxResults = parseInt($get("maxResults"));
      EventsDwr.searchOld(eventId, $get("eventSourceType"), $get("eventStatus"), $get("alarmLevel"),
        $get("keywords"), maxResults, function(results) {
          $set("searchResults", results.data.content);
          setDisabled("searchBtn", false);
          $set("searchMessage", results.data.resultCount);
        });
    }

    function doSearch(page, date) {
      setDisabled("searchBtn", true);
      $set("searchMessage", "<fmt:message key='events.search.searching'/>");
      var eventId = parseInt($get("eventId"));
      EventsDwr.search(eventId, $get("eventSourceType"), $get("eventStatus"), $get("alarmLevel"),
        $get("keywords"), page.value, date.value, function(results) {
          $set("searchResults", results.data.content);
          setDisabled("searchBtn", false);
          $set("searchMessage", results.data.resultCount);
        });
    }

    function jumpToDate(parent) {
      var div = $("datePickerDiv");
      var bounds = getAbsoluteNodeBounds(parent);
      div.style.top = bounds.y + "px";
      div.style.left = bounds.x + "px";
      var x = dojo.widget.byId("datePicker");
      x.show();
    }

    var dptimeout = null;

    function expireDatePicker() {
      dptimeout = setTimeout(function() {
        dojo.widget.byId("datePicker").hide();
      }, 500);
    }

    function cancelDatePickerExpiry() {
      if (dptimeout) {
        clearTimeout(dptimeout);
        dptimeout = null;
      }
    }

    function jumpToDateClicked(date) {
      var x = dojo.widget.byId("datePicker");
      if (x.isShowing()) {
        x.hide();
        doSearch(0, date);
      }
    }

    function newSearch() {
      // var x = dojo.widget.byId("datePicker");
      // console.log(x);
      // x.setDate(x.today);
      time = new Date($("datePicker"));

      // doSearch(0,time.getTime());
      console.log("newSearch");
      if (!isValid(eventId.value)) {
        $set("searchMessage", $get("eventIdLabel") + " - Incorrect input data type");
      } else if (!isValid(maxResults.value)) {
        $set("searchMessage", $get("maxResultsLabel") + " - Incorrect input data type");
      } else {
        doSearchOld();
      }
    }

    function isValid(value) {
      return value == "" || isPositiveInt(value);
    }

    function isPositiveInt(value) {
      return isInt32(value) && value >= 0;
    }

    function silenceAll() {
      MiscDwr.silenceAll(function(result) {
        var silenced = result.data.silenced;
        for (var i = 0; i < silenced.length; i++)
          setSilenced(silenced[i], true);
      });
    }

    function parseInt(value) {
      return value == "" ? 0 : Number.parseInt(value);
    }

    // dojo.addOnLoad(function() {
    // var x = dojo.widget.byId("datePicker");
    // x.hide();
    // x.setDate(x.today);
    // dojo.event.connect(x,'onValueChanged','jumpToDateClicked');
    // });
  </script>
  <div class="borderDiv marB marR container">
    <div class="left-box">
      <div class="top-row-box mb-3">
        <div class="box-description sound-icon">
          <span class="smallTitle"><fmt:message key="events.pending"/></span>
          <%-- <tag:help id="events"/> --%>
          <i href="#" class="nav-link" title="<fmt:message key='events.alarms'/>"></i>
          <i class="bi bi-flag ms-3 me-3"></i>
        </div>
        <div id="ackAllDiv" class="titlePadding" style="display:none;">
          <span style="font-size: 16px;">
            <fmt:message key="events.acknowledgeAll"/>
            </span>
            <a href="#" class="nav-link" onclick="MiscDwr.acknowledgeAllPendingEvents()" title="<fmt:message key='events.acknowledgeAll'/>">
              <i class="bi bi-check ms-3 me-3 text-blue-add"></i>
            </a>
          <div class="vr custom-vr me-2"></div>
          <span style="font-size: 16px;">
            <fmt:message key="events.silenceAll"/>
          </span>
          <a href="#" class="nav-link" onclick="silenceAll()" title="<fmt:message key='events.silenceAll'/>">
            <i class="bi bi-volume-mute ms-3 me-3 text-blue-add"></i>
          </a>
          <br/>
        </div>
      </div>
      <div id="pendingAlarms" style="clear:both;"></div>
      <div id="noAlarms" style="display:none;padding:6px;text-align:center;">
        <b><fmt:message key="events.emptyList"/></b>
      </div>
      <div id="hourglass" style="padding:6px;text-align:center;">
        <i class="bi bi-hourglass-split"></i>
      </div>
    </div>
    </div>
  <div class="borderDiv marB marR container">
    <div class="top-row-box mb-3">
        <div class="box-description sound-icon">
          <span class="smallTitle"><fmt:message key="events.search"/></span>
        </div>
      </div>
    <%-- <div class="smallTitle titlePadding">
      <fmt:message key="events.search"/>
    </div> --%>
    <div>
      <table><div class="ms-5 me-5 mb-3 row g-1">
        <div class="col">
        <div class="mb-3 row">
            <label for="eventIdLabel" class="col-sm-2 col-form-label custom-padding-l"><fmt:message key="events.id"/></label>
            <div class="col-sm-3 custom-padding-is">
              <input type="text" class="form-control form-control-sm" id="eventId">
            </div>
        </div>
        <div class="mb-3 row">
          <label for="eventSourceType" class="col-sm-2 col-form-label custom-padding-l"><fmt:message key="events.search.type"/></label>
          <div class="col-sm-6 custom-padding-is">
            <select class="form-select form-select-sm" id="eventSourceType">
            <option value="-1">
                <fmt:message key="common.all"/>
              </option>
              <option value="<c:out value='<%= EventType.EventSources.DATA_POINT %>'/>">
                <fmt:message key="eventHandlers.pointEventDetector"/>
              </option>
              <option value="<c:out value='<%= EventType.EventSources.SCHEDULED %>'/>">
                <fmt:message key="scheduledEvents.ses"/>
              </option>
              <option value="<c:out value='<%= EventType.EventSources.COMPOUND %>'/>">
                <fmt:message key="compoundDetectors.compoundEventDetectors"/>
              </option>
              <option value="<c:out value='<%= EventType.EventSources.DATA_SOURCE %>'/>">
                <fmt:message key="eventHandlers.dataSourceEvents"/>
              </option>
              <option value="<c:out value='<%= EventType.EventSources.PUBLISHER %>'/>">
                <fmt:message key="eventHandlers.publisherEvents"/>
              </option>
              <option value="<c:out value='<%= EventType.EventSources.MAINTENANCE %>'/>">
                <fmt:message key="eventHandlers.maintenanceEvents"/>
              </option>
              <option value="<c:out value='<%= EventType.EventSources.SYSTEM %>'/>">
                <fmt:message key="eventHandlers.systemEvents"/>
              </option>
              <option value="<c:out value='<%= EventType.EventSources.AUDIT %>'/>">
                <fmt:message key="eventHandlers.auditEvents"/>
              </option>
            </select>
          </div>
        </div>
        <div class="mb-3 row">
          <label for="eventStatus" class="col-sm-2 col-form-label custom-padding-l"><fmt:message key="common.status"/></label>
          <div class="col-sm-6 custom-padding-is">
            <select class="form-select form-select-sm" id="eventStatus">
              <option value="<c:out value='<%= EventsDwr.STATUS_ALL %>'/>">
                <fmt:message key="common.all"/>
              </option>
              <option value="<c:out value='<%= EventsDwr.STATUS_ACTIVE %>'/>">
                <fmt:message key="common.active"/>
              </option>
              <option value="<c:out value='<%= EventsDwr.STATUS_RTN %>'/>">
                <fmt:message key="event.rtn.rtn"/>
              </option>
              <option value="<c:out value='<%= EventsDwr.STATUS_NORTN %>'/>">
                <fmt:message key="common.nortn"/>
              </option>
            </select>
          </div>
        </div>
        </div>
        <div class="col">
        <div class="mb-3 row">
          <label for="alarmLevel" class="col-sm-2 col-form-label custom-padding-l"><fmt:message key="common.alarmLevel"/></label>
          <div class="col-sm-4 custom-padding-is">
            <select class="form-select form-select-sm" id="alarmLevel">
              <tag:alarmLevelOptions allOption="true"/>
            </select>
          </div>
        </div>
          <div class="mb-3 row">
              <label for="keywords" class="col-sm-2 col-form-label custom-padding-l"><fmt:message key="events.search.keywords"/></label>
              <div class="col-sm-9 custom-padding-is">
                <input type="text" class="form-control form-control-sm" id="keywords">
              </div>
          </div>
          <div class="mb-3 row">
              <label for="maxResults" class="col-sm-2 col-form-label custom-padding-l"><fmt:message key="events.search.maxResults"/></label>
              <div class="col-sm-4 custom-padding-is">
                <input type="number" class="form-control form-control-sm" id="maxResults" min="1" max="1000000000" value="500">
              </div>
          </div>
        </div>
        <div class="mb-3 row">
          <div class="align-self-end">
            <button id="searchBtn" type="button" class="btn btn-primary custom-btn-blue" name="searchBtn"  onclick="newSearch()"><fmt:message key="events.search.search"/></button>
          </div>
          <td colspan="24" align="center">
            <span id="searchMessage" class="formError"></span>
          </td>
        </div>
        </div>
        
          
      </table>
    </div>
    <div id="searchResults"></div>
  </div>
</tag:page>