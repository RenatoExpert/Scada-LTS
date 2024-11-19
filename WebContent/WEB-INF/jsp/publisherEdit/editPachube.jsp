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
<script type="text/javascript">
  var allPoints = new Array();
  var selectedPoints = new Array();
  
  dojo.addOnLoad(function() {
      PublisherEditDwr.initSender(function(response) {
          var i;
          var list = response.data.allPoints;
          for (var i=0; i<list.length; i++)
              allPoints[allPoints.length] = {
                      id: list[i].id, name: list[i].extendedName, enabled: list[i].enabled, type: list[i].dataTypeMessage};
              
          list = response.data.publisher.points;
          for (i=0; i<list.length; i++)
              addToSelectedArray(list[i].dataPointId, list[i].feedId, list[i].dataStreamId);
          refreshSelectedPoints();
      });
  });
  
  function selectPoint() {
      var pointId = $get("availablePoints");
      addToSelectedArray(pointId, "", "");
      refreshSelectedPoints();
  }
  
  function addToSelectedArray(pointId, feedId, dataStreamId) {
      var data = getElement(allPoints, pointId);
      
      if (data) {
          // Missing names imply that the point was deleted, so ignore.
          selectedPoints[selectedPoints.length] = {
              id : pointId,
              pointName : data.name,
              enabled : data.enabled,
              pointType : data.type,
              feedId: feedId,
              dataStreamId: dataStreamId
          };
      }
  }
  
  function removeFromSelectedPoints(pointId) {
      removeElement(selectedPoints, pointId);
      refreshSelectedPoints();
  }
  
  function refreshSelectedPoints() {
      dwr.util.removeAllRows("selectedPoints");
      if (selectedPoints.length == 0)
          show("selectedPointsEmpty");
      else {
          hide("selectedPointsEmpty");
          dwr.util.addRows("selectedPoints", selectedPoints,
              [
                  function(data) { return data.pointName; },
                  function(data) { return "<i class='"+ (data.enabled ? "bi bi-puzzle-fill text-blue-add  align-middle me-2 fs-5" : "bi bi-puzzle-fill text-danger align-middle me-2 fs-5") +"'></i>"; },
                  function(data) { return data.pointType; },
                  function(data) {
                          return "<input class='form-control form-control-sm' type='text' value='"+ data.feedId +"' "+
                                  "onblur='updateFeedId("+ data.id +", this.value)'/>";
                  },
                  function(data) {return "<input class='form-control form-control-sm' type='text' value='"+ data.dataStreamId +"' "+
                                  "onblur='updateDataStreamId("+ data.id +", this.value)'/>";
                  },
                  function(data) {return "<i class='bi bi-trash text-danger align-middle me-2 fs-5' "+
                                  "onclick='removeFromSelectedPoints("+ data.id +")'></i>";
                  }
              ],
              {
                  rowCreator: function(options) {
                      var tr = document.createElement("tr");
                      tr.className = "rowTable"+ (options.rowIndex % 2 == 0 ? "" : "Alt");
                      return tr;
                  },
                  cellCreator: function(options) {
                      var td = document.createElement("td");
                      if (options.cellNum == 1 || options.cellNum == 4)
                          td.align = "center";
                      return td;
                  } 
              });
      }
      refreshAvailablePoints();
  }
  
  function refreshAvailablePoints() {
      dwr.util.removeAllOptions("availablePoints");
      var availPoints = new Array();
      for (var i=0; i<allPoints.length; i++) {
          var found = false;
          for (var j=0; j<selectedPoints.length; j++) {
              if (selectedPoints[j].id == allPoints[i].id) {
                  found = true;
                  break;
              }
          }
          
          if (!found)
              availPoints[availPoints.length] = allPoints[i];
      }
      dwr.util.addOptions("availablePoints", availPoints, "id", "name");
  }
  
  function updateFeedId(pointId, feedId) {
      updateElement(selectedPoints, pointId, "feedId", feedId);
  }
  
  function updateDataStreamId(pointId, dataStreamId) {
      updateElement(selectedPoints, pointId, "dataStreamId", dataStreamId);
  }
  
  function savePublisherImpl(name, xid, enabled, cacheWarningSize, changesOnly, sendSnapshot, snapshotSendPeriods,
          snapshotSendPeriodType) {
      // Clear messages.
      hide("apiKeyMsg");
      hide("timeoutSecondsMsg");
      hide("retriesMsg");
      hide("pointsMsg");
      
      var points = new Array();
      for (var i=0; i<selectedPoints.length; i++)
          points[points.length] = {dataPointId: selectedPoints[i].id, feedId: selectedPoints[i].feedId,
                  dataStreamId: selectedPoints[i].dataStreamId};
      
      PublisherEditDwr.savePachubeSender(name, xid, enabled, points, $get("apiKey"), $get("timeoutSeconds"),
              $get("retries"), cacheWarningSize, changesOnly, sendSnapshot, snapshotSendPeriods, snapshotSendPeriodType,
              savePublisherCB);
  }
</script>

<table cellpadding="0" cellspacing="0">
  <tr>
    <td valign="top">
      <div class="right-box my-3">
        <table class="m-3">
          <tr>
            <td colspan="2" class="smallTitle"><fmt:message key="publisherEdit.pachube.props"/><tag:help id="pachubePublishing"/></td>
          </tr>
          
          <tr>
            <td class="formLabelRequired align-middle my-2"><fmt:message key="publisherEdit.pachube.apiKey"/></td>
            <td class="formField">
              <input class='form-control form-control-sm my-2' type="text" id="apiKey" value="${publisher.apiKey}" class="formLong"/>
              <div id="apiKeyMsg" class="formError" style="display:none;"></div>
            </td>
          </tr>
          
          <tr>
            <td class="formLabelRequired align-middle my-2"><fmt:message key="publisherEdit.pachube.timeoutSeconds"/></td>
            <td class="formField">
              <input class='form-control form-control-sm my-2' type="text" id="timeoutSeconds" value="${publisher.timeoutSeconds}"/>
              <div id="timeoutSecondsMsg" class="formError" style="display:none;"></div>
            </td>
          </tr>
          
          <tr>
            <td class="formLabelRequired align-middle my-2"><fmt:message key="publisherEdit.pachube.retries"/></td>
            <td class="formField">
              <input class='form-control form-control-sm my-2' type="text" id="retries" value="${publisher.retries}"/>
              <div id="retriesMsg" class="formError" style="display:none;"></div>
            </td>
          </tr>
        </table>
      </div>
    </td>
  </tr>
</table>

<table cellpadding="0" cellspacing="0"><tr><td>
  <div class="right-box my-3 w-100">
    <table class="w-100">
      <tr>
        <div class="container">
          <div class="row align-items-center">
            <div class="col-auto smallTitle">
              <fmt:message key="publisherEdit.points"/>
            </div>
            <div class="col-auto">
              <select class="form-select form-select-sm my-2" id="availablePoints"></select>
            </div>
            <div class="col-auto">
              <i class="bi bi-plus-circle-fill text-blue-add  align-middle me-2 fs-5" onclick="selectPoint()"></i>
            </div>
          </div>
        </div>
      </tr>
    </table>

    <div id="httpSenderTest" ></div>
    
    <table cellspacing="1" cellpadding="0" class="table table-light table-hover align-middle">
      <tr class="rowHeader">
        <td><fmt:message key="publisherEdit.point.name"/></td>
        <td><fmt:message key="publisherEdit.point.status"/></td>
        <td><fmt:message key="publisherEdit.point.type"/></td>
        <td><fmt:message key="publisherEdit.pachube.point.feedId"/></td>
        <td><fmt:message key="publisherEdit.pachube.point.dataStreamId"/></td>
        <td></td>
      </tr>
      <tbody id="selectedPointsEmpty" style="display:none;"><tr><td colspan="5"><fmt:message key="publisherEdit.noPoints"/></td></tr></tbody>
      <tbody id="selectedPoints"></tbody>
    </table>
    <div id="pointsMsg" class="formError" style="display:none;"></div>
  </div>
</td></tr></table>