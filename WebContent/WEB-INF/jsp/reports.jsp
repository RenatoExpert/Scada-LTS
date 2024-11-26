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
<%@page import="com.serotonin.mango.Common"%>
<%@page import="com.serotonin.mango.vo.report.ReportVO"%>
<%@page import="com.serotonin.mango.vo.report.ReportInstance"%>

<tag:page dwr="ReportsDwr" js="emailRecipients" onload="init">
  <script type="text/javascript">
    var allPointsArray = new Array();
    var reportPointsArray;
    var selectedReport;
    var emailRecipients;
    
    function init() {
        ReportsDwr.init(function(response) {
            hide("hourglass");
            allPointsArray = response.data.points;
            
            emailRecipients = new mango.erecip.EmailRecipients("recipients",
                    "<fmt:message key="reports.recipTestEmailMessage"/>", response.data.mailingLists, response.data.users);
            emailRecipients.write("emailRecipBody", "emailRecipients", null, "<fmt:message key="reports.emailRecipients"/>");
            
            updateReportInstancesList(response.data.instances);
            
            for (var i=0; i<response.data.reports.length; i++) {
                appendReport(response.data.reports[i].id);
                updateReport(response.data.reports[i].id, response.data.reports[i].name);
            }
            
            <c:if test="${!empty param.wlid}">
              ReportsDwr.createReportFromWatchlist(${param.wlid}, loadReportCB);
            </c:if>
        });
    }
    
    function loadReport(reportId, copy) {
        if (selectedReport)
            stopImageFader("r"+ selectedReport.id +"Img");
        
        ReportsDwr.getReport(reportId, copy, loadReportCB);
        
        if (copy)
            reportId = <c:out value="<%= Common.NEW_ID %>"/>;
        
        startImageFader("r"+ reportId +"Img");
        display("deleteImg", reportId != <c:out value="<%= Common.NEW_ID %>"/>);
        display("copyImg", reportId != <c:out value="<%= Common.NEW_ID %>"/>);
    }
    
    function loadReportCB(report) {
        if (!report)
            return;
        if (!selectedReport)
            show($("reportDetails"));
        selectedReport = report;
        
        $set("name", report.name);
        reportPointsArray = new Array();
        for (var i=0; i<report.points.length; i++)
            addToReportPointsArray(report.points[i].pointId, report.points[i].colour,
                    report.points[i].consolidatedChart);
        $set("includeEvents", report.includeEvents);
        $set("includeUserComments", report.includeUserComments);
        $set("dateRangeType", report.dateRangeType);
        $set("relativeType", report.relativeDateType);
        $set("prevPeriodCount", report.previousPeriodCount);
        $set("prevPeriodType", report.previousPeriodType);
        $set("pastPeriodCount", report.pastPeriodCount);
        $set("pastPeriodType", report.pastPeriodType);
        
        $set("fromYear", report.fromYear);
        $set("fromMonth", report.fromMonth);
        $set("fromDay", report.fromDay);
        $set("fromHour", report.fromHour);
        $set("fromMinute", report.fromMinute);
        $set("fromNone", report.fromNone);
        
        $set("toYear", report.toYear);
        $set("toMonth", report.toMonth);
        $set("toDay", report.toDay);
        $set("toHour", report.toHour);
        $set("toMinute", report.toMinute);
        $set("toNone", report.toNone);
        
        $set("schedule", report.schedule);
        $set("schedulePeriod", report.schedulePeriod);
        $set("runDelayMinutes", report.runDelayMinutes);
        $set("scheduleCron", report.scheduleCron);
        
        $set("email", report.email);
        $set("includeData", report.includeData);
        $set("zipData", report.zipData);
        emailRecipients.updateRecipientList(report.recipients);
        
        showMessage("userMessage");
  
        writeReportPointsArray();
        updateDateRangeFields();
        updateScheduleFields();
        updateSchedulePeriodFields();
        updateEmailFields();
    }
    
    function addPointToReport() {
        var pointId = $get("allPointsList");
        addToReportPointsArray(pointId, "", true);
        writeReportPointsArray();
    }
    
    function addToReportPointsArray(pointId, colour, consolidatedChart) {
        var data = getPointData(pointId);
        if (data) {
            // Missing names imply that the point was deleted, so ignore.
            reportPointsArray[reportPointsArray.length] = {
                pointId: pointId,
                pointXid: data.xid,
                pointName : data.name,
                pointType : data.dataTypeMessage,
                colour : !colour ? (!data.chartColour ? "" : data.chartColour) : colour,
                consolidatedChart : consolidatedChart
            };
        }
    }
    
    function getPointData(pointId) {
        for (var i=0; i<allPointsArray.length; i++) {
            if (allPointsArray[i].id == pointId)
                return allPointsArray[i];
        }
        return null;
    }
    
    function writeReportPointsArray() {
        dwr.util.removeAllRows("reportPointsTable");
        if (reportPointsArray.length == 0) {
            show($("reportPointsTableEmpty"));
            hide($("reportPointsTableHeaders"));
        }
        else {
            hide($("reportPointsTableEmpty"));
            show($("reportPointsTableHeaders"));
            dwr.util.addRows("reportPointsTable", reportPointsArray,
                [
                    function(data) { return data.pointName; },
                    function(data) { return data.pointType; },
                    function(data) {
                            return "<input class='w-100 form-control form-control-sm' type='text' value='"+ data.colour +"' "+
                                    "onblur='updatePointColour("+ data.pointId +", this.value)'/>";
                    },
                    function(data) {
                        return "<input class='form-check-input custom-checkbox my-2' type='checkbox'"+ (data.consolidatedChart ? " checked='checked'" : "") +
                                " onclick='updatePointConsolidatedChart("+ data.pointId +", this.checked)'/>";
                    },
                    function(data) { 
                        return "<i class='bi bi-trash text-danger me-2 fs-5' onclick='removeFromReportPointsArray(" + data.pointId + ")'></i>";
                    }
                ],
                {
                    rowCreator:function(options) {
                        var tr = document.createElement("tr");
                        tr.className = "align-middle smRow"+ (options.rowIndex % 2 == 0 ? "" : "Alt");
                        return tr;
                    },
                    cellCreator:function(options) {
                        var td = document.createElement("td");
                        if (options.cellNum == 3)
                            td.align = "center";
                        return td;
                    }
                });
        }
        updatePointsList();
    }
    
    function updatePointColour(pointId, colour) {
        var item = getElement(reportPointsArray, pointId, "pointId");
        if (item)
            item["colour"] = colour;
    }
    
    function updatePointConsolidatedChart(pointId, consolidatedChart) {
        var item = getElement(reportPointsArray, pointId, "pointId");
        if (item)
            item["consolidatedChart"] = consolidatedChart;
    }
    
    function updatePointsList() {
        dwr.util.removeAllOptions("allPointsList");
        var availPoints = new Array();
        for (var i=0; i<allPointsArray.length; i++) {
            var found = false;
            for (var j=0; j<reportPointsArray.length; j++) {
                if (reportPointsArray[j].pointId == allPointsArray[i].id) {
                    found = true;
                    break;
                }
            }
            
            if (!found)
                availPoints[availPoints.length] = allPointsArray[i];
        }
        dwr.util.addOptions("allPointsList", availPoints, "id", "name");
    }
    
    function removeFromReportPointsArray(pointId) {
        for (var i=reportPointsArray.length-1; i>=0; i--) {
            if (reportPointsArray[i].pointId == pointId)
                reportPointsArray.splice(i, 1);
        }
        writeReportPointsArray();
    }
    
    function updateReportInstancesList(instanceArray) {
        stopImageFader("reportInstancesRefreshImg");
        dwr.util.removeAllRows("reportInstancesList");
        if (instanceArray.length == 0)
            show("noReportInstances");
        else {
            hide("noReportInstances");
            dwr.util.addRows("reportInstancesList", instanceArray,
                [
                    function(ri) { return ri.name; },
                    function(ri) { return ri.prettyRunStartTime; },
                    function(ri) { return ri.prettyRunDuration; },
                    function(ri) { return ri.prettyReportStartTime; },
                    function(ri) { return ri.prettyReportEndTime; },
                    function(ri) { return ri.prettyRecordCount; },
                    function(ri) {
                        return "<input class='form-check-input custom-checkbox my-2' class='form-check-input custom-checkbox my-2' type='checkbox'"+ (ri.preventPurge ? " checked='checked'" : "") +
                                " onclick='ReportsDwr.setPreventPurge("+ ri.id +", this.checked)'/>";
                    },
                    function(ri) { 
                        if (ri.state == <c:out value="<%= ReportInstance.STATE_NOT_STARTED %>"/> ||
                                ri.state == <c:out value="<%= ReportInstance.STATE_STARTED %>"/>)
                            return "";
                            
                        var result = "<i class='bi bi-filetype-csv text-success me-2 fs-5' title='<fmt:message key="reports.export"/>' "+
                                "onclick='exportData(\""+ encodeQuotes(ri.name) +"\", "+ ri.id +")'></i>";
                        
                        if (ri.includeEvents != <c:out value="<%= ReportVO.EVENTS_NONE %>"/>)
                            result += "<i class='bi bi-calendar-check text-primary me-2 fs-5' title='<fmt:message key="reports.eventExport"/>' "+
                                    "onclick='exportEventData(\""+ encodeQuotes(ri.name) +"\", "+ ri.id +")'></i>";
                        
                        if (ri.includeUserComments)
                            result += "<i class='bi bi-chat-dots text-success me-2 fs-5' title='<fmt:message key="reports.userCommentExport"/>' "+
                                    "onclick='exportUserComments(\""+ encodeQuotes(ri.name) +"\", "+ ri.id +")'></i>";
                        
                        result += "<i class='bi bi-graph-up-arrow text-success me-2 fs-5' title='<fmt:message key="reports.charts"/>' "+
                                "onclick='viewChart("+ ri.id +")'></i>"+
                                "<i id='ri"+ ri.id +"DeleteImg' class='bi bi-trash text-danger me-2 fs-5' "+
                                "onclick='deleteReportInstance("+ ri.id +")'></i> ";
                        
                        return result;
                    }
                ],
                {
                    rowCreator: function(options) {
                        var tr = document.createElement("tr");
                        tr.className = "align-middle rowTable"+ (options.rowIndex % 2 == 0 ? "" : "Alt");
                        return tr;
                    },
                    cellCreator: function(options) {
                        var td = document.createElement("td");
                        if (options.cellNum == 5)
                            td.align = "center";
                        if (options.cellNum == 6)
                            td.align = "center";
                        return td;
                    }
                });
        }
    }
    
    function deleteReportInstance(instanceId) {
        var img = $("ri"+ instanceId +"DeleteImg");
        img.src = "images/bullet_black.png";
        img.onclick = null;
        dojo.html.removeClass(img, "ptr");
        startImageFader("reportInstancesRefreshImg");
        ReportsDwr.deleteReportInstance(instanceId, updateReportInstancesList);
    }
    
    function exportData(name, instanceId) {
        window.location = "export/"+ name +".csv?instanceId="+ instanceId;
    }
    
    function exportEventData(name, instanceId) {
        window.location = "eventExport/"+ name +"Events.csv?instanceId="+ instanceId;
    }
    
    function exportUserComments(name, instanceId) {
        window.location = "userCommentExport/"+ name +"Comments.csv?instanceId="+ instanceId;
    }
    
    function viewChart(instanceId) {
        window.open("reportChart.shtm?instanceId="+ instanceId, "chartTarget");
    }
    
    function refreshReportInstanceList() {
        ReportsDwr.getReportInstances(updateReportInstancesList);
        startImageFader("reportInstancesRefreshImg");
    }
    
    function updateDateRangeFields() {
        var dateRangeType = $get("dateRangeType");
        if (dateRangeType == 1) {
            setDisabled("relprev", false);
            setDisabled("relpast", false);
        
            var relativeType = $get("relativeType");
            if (relativeType == 1) {
                setDisabled("prevPeriodCount", false);
                setDisabled("prevPeriodType", false);
                setDisabled("pastPeriodCount", true);
                setDisabled("pastPeriodType", true);
            }
            else {
                setDisabled("prevPeriodCount", true);
                setDisabled("prevPeriodType", true);
                setDisabled("pastPeriodCount", false);
                setDisabled("pastPeriodType", false);
            }
            
            setDisabled("fromYear", true);
            setDisabled("fromMonth", true);
            setDisabled("fromDay", true);
            setDisabled("fromHour", true);
            setDisabled("fromMinute", true);
            setDisabled("fromNone", true);
            setDisabled("toYear", true);
            setDisabled("toMonth", true);
            setDisabled("toDay", true);
            setDisabled("toHour", true);
            setDisabled("toMinute", true);
            setDisabled("toNone", true);
        }
        else {
            setDisabled("relprev", true);
            setDisabled("relpast", true);
            setDisabled("prevPeriodCount", true);
            setDisabled("prevPeriodType", true);
            setDisabled("pastPeriodCount", true);
            setDisabled("pastPeriodType", true);
            
            var inception = $get("fromNone");
            setDisabled("fromYear", inception);
            setDisabled("fromMonth", inception);
            setDisabled("fromDay", inception);
            setDisabled("fromHour", inception);
            setDisabled("fromMinute", inception);
            setDisabled("fromNone", false);
            
            var now = $get("toNone");
            setDisabled("toYear", now);
            setDisabled("toMonth", now);
            setDisabled("toDay", now);
            setDisabled("toHour", now);
            setDisabled("toMinute", now);
            setDisabled("toNone", false);
        }
    }
    
    function updateScheduleFields() {
        display("scheduleDetails", $get("schedule"));
    }
    
    function updateSchedulePeriodFields() {
        var schedulePeriod = $get("schedulePeriod");
        setDisabled("runDelayMinutes", schedulePeriod == <c:out value="<%= ReportVO.SCHEDULE_CRON %>"/>);
        setDisabled("scheduleCron", schedulePeriod != <c:out value="<%= ReportVO.SCHEDULE_CRON %>"/>);
    }
    
    function updateEmailFields() {
        var email = $get("email");
        display("emailDetails", email);
        display("emailRecipBody", email);
    }
    
    function getReportPointIdsArray() {
        var points = new Array();
        for (var i=0; i<reportPointsArray.length; i++)
            points[points.length] = {
                pointId: reportPointsArray[i].pointId,
                pointXid: reportPointsArray[i].pointXid,
                colour: reportPointsArray[i].colour,
                consolidatedChart: reportPointsArray[i].consolidatedChart
            };
        return points;
    }
    
    function saveReport() {
        startImageFader("saveImg");
        ReportsDwr.saveReport(selectedReport.id, $get("name"), getReportPointIdsArray(), $get("includeEvents"),
                $get("includeUserComments"), $get("dateRangeType"), $get("relativeType"), $get("prevPeriodCount"),
                $get("prevPeriodType"), $get("pastPeriodCount"), $get("pastPeriodType"), $get("fromNone"),
                $get("fromYear"), $get("fromMonth"), $get("fromDay"), $get("fromHour"), $get("fromMinute"),
                $get("toNone"), $get("toYear"), $get("toMonth"), $get("toDay"), $get("toHour"), $get("toMinute"),
                $get("schedule"), $get("schedulePeriod"), $get("runDelayMinutes"), $get("scheduleCron"), $get("email"),
                $get("includeData"), $get("zipData"), emailRecipients.createRecipientArray(), function(response) {
            stopImageFader("saveImg");
            clearMessages();
            
            if (response.hasMessages)
                showMessages(response.messages);
            else {
                if (selectedReport.id == <c:out value="<%= Common.NEW_ID %>"/>) {
                    stopImageFader("r"+ selectedReport.id +"Img");
                    selectedReport.id = response.data.reportId;
                    appendReport(selectedReport.id);
                    startImageFader("r"+ selectedReport.id +"Img");
                    showMessage("userMessage", "<fmt:message key="reports.reportAdded"/>");
                    show("deleteImg");
                    show("copyImg");
                }
                else
                    showMessage("userMessage", "<fmt:message key="reports.reportSaved"/>");
                updateReport(selectedReport.id, $get("name"));
            }
        });
        startImageFader("saveImg");
    }
    
    function appendReport(reportId) {
        createFromTemplate("r_TEMPLATE_", reportId, "reportsTable");
    }
    
    function updateReport(id, name) {
        $("r"+ id +"Name").innerHTML = name;
    }
    
    function clearMessages() {
        showMessage("userMessage");
        showMessage("nameError");
        showMessage("pointsError");
        showMessage("previousPeriodCountError");
        showMessage("pastPeriodCountError");
        showMessage("runDelayMinutesError");
        showMessage("scheduleCronError");
        showMessage("recipientsError");
    }
    
    function showMessages(messages) {
        for (var i=0; i<messages.length; i++) {
            if (messages[i].contextKey)
                showMessage(messages[i].contextKey +"Error", messages[i].contextualMessage);
            else
                alert(messages[i].genericMessage);
        }
    }
  
    function deleteReport() {
        ReportsDwr.deleteReport(selectedReport.id);
        stopImageFader("r"+ selectedReport.id +"Img");
        $("reportsTable").removeChild($("r"+ selectedReport.id));
        hide("reportDetails");
        selectedReport = null;
    }
    
    function runReport() {
        if (hasImageFader("runImg"))
            return;
        
        ReportsDwr.runReport($get("name"), getReportPointIdsArray(), $get("includeEvents"),
                $get("includeUserComments"), $get("dateRangeType"), $get("relativeType"), $get("prevPeriodCount"),
                $get("prevPeriodType"), $get("pastPeriodCount"), $get("pastPeriodType"), $get("fromNone"),
                $get("fromYear"), $get("fromMonth"), $get("fromDay"), $get("fromHour"), $get("fromMinute"),
                $get("toNone"), $get("toYear"), $get("toMonth"), $get("toDay"), $get("toHour"), $get("toMinute"),
                $get("email"), $get("includeData"), $get("zipData"), emailRecipients.createRecipientArray(), function(response) {
            stopImageFader("runImg");
            clearMessages();
            
            if (response.hasMessages)
                showMessages(response.messages);
            else {
                showMessage("userMessage", "<fmt:message key="reports.reportQueued"/>");
                refreshReportInstanceList();
            }
        });
        startImageFader("runImg");
    }
  </script>
  
  <table cellpadding="0" cellspacing="0" class="subPageHeader container"><tr><td>
    <div class="right-box w-100 m-3" style="max-height:300px;overflow:auto;">
      <table class="w-100">
        <tr>
          <td>
            <span class="smallTitle m-3"><fmt:message key="reports.reportQueue"/></span>
            <tag:help id="reportInstances"/>
          </td>
        <td align="right">
            <i id="reportInstancesRefreshImg" class="bi bi-arrow-clockwise ms-2 fs-5" title="<fmt:message key='common.refresh'/>" onclick="refreshReportInstanceList()"></i>
        </td>
        </tr>
      </table>
      
      <table cellspacing="1" class="fs-7 text-center table table-light table-hover my-2">
        <tr class="align-middle rowHeader">
          <td><fmt:message key="reports.reportName"/></td>
          <td><fmt:message key="reports.runTimeStart"/></td>
          <td><fmt:message key="reports.runDuration"/></td>
          <td><fmt:message key="common.dateRangeFrom"/></td>
          <td><fmt:message key="common.dateRangeTo"/></td>
          <td><fmt:message key="reports.reportRecords"/></td>
          <td><fmt:message key="reports.doNotPurge"/></td>
          <td></td>
        </tr>
        <tr id="hourglass" class="align-middle rowTable"><td colspan="8" align="center"><i class="bi bi-hourglass-split me-2 fs-5" title="<fmt:message key='reports.loading'/>"></i></td></tr>
        <tr id="noReportInstances" class="align-middle rowTable" style="display:none;"><td colspan="8"><fmt:message key="reports.noInstances"/></td></tr>
        <tbody id="reportInstancesList"></tbody>
      </table>
    </div>
  </td></tr></table>
  
  <table cellpadding="0" cellspacing="0" class="subPageHeader container">
    <tr>
      <td valign="top">
        <div class="left-menu w-100 mx-3">
          <table class="w-100">
            <tr>
              <td>
                <span class="smallTitle ms-3"><fmt:message key="reports.templates"/></span>
                <tag:help id="reportTemplates"/>
              </td>
              <td align="right">
                  <i class="bi bi-plus-circle-fill text-blue-add ms-2 fs-5" title="<fmt:message key='reports.newReport'/>" onclick="loadReport(${applicationScope['constants.Common.NEW_ID']}, false)" id="r${applicationScope['constants.Common.NEW_ID']}Img"></i>
              </td>
            </tr>
          </table>
          <table id="reportsTable" class="text-uppercase align-middle fs-7 m-3">
            <tbody id="r_TEMPLATE_" onclick="loadReport(getMangoId(this), false)" class="ptr" style="display:none;"><tr>
              <td>
                  <i id="r_TEMPLATE_Img" class="bi bi-journal-text me-2 fs-5" title="<fmt:message key='reports.report'/>"></i>
              </td>
              <td class="link" id="r_TEMPLATE_Name" style="text-decoration: none;"></td>
            </tr></tbody>
          </table>
        </div>
      </td>
      
      <td valign="top" id="reportDetails" style="display:none;">
        <div class="right-box w-75 mx-4">
          <table class="w-100 my-3">
            <tr>
              <td>
                <span class="smallTitle">
                <i id="reportImg" class="bi bi-journal-text m-3 fs-5" title="<fmt:message key='reports.report'/>"></i>
                <fmt:message key="reports.criteria"/></span>
              </td>
              <td align="right">
                  <i id="deleteImg" class="bi bi-trash  text-danger me-2 fs-5" title="<fmt:message key='common.delete'/>" onclick="deleteReport();"></i>
                  <i id="runImg" class="bi bi-caret-right-square-fill text-success me-2 fs-5" title="<fmt:message key='reports.runNow'/>" onclick="runReport();"></i>
                  <i id="saveImg" class="bi bi-floppy2-fill text-success me-2 fs-5" title="<fmt:message key='common.save'/>" onclick="saveReport();"></i>
                  <i id="copyImg" class="bi bi-journals text-primary me-2 fs-5" title="<fmt:message key='common.copy'/>" onclick="loadReport(selectedReport.id, true);"></i>
              </td>
            </tr>
            <tr><td class="formError" id="userMessage"></td></tr>
          </table>
          
          <table>
            <tr>
              <td class="formLabelRequired align-middle my-2"><fmt:message key="reports.reportName"/></td>
              <td class="d-flex align-items-center justify-content-start">
                <input class="w-75 form-control form-control-sm my-2" type="text" id="name" class="formLong"/><br/>
                <span class="formError ms-2" id="nameError"></span>
              </td>
            </tr>
            
            <tr>
              <td class="formLabelRequired align-middle my-2"><fmt:message key="common.points"/></td>
                <td class="d-flex align-items-center justify-content-start">
                  <select class="w-75 form-select form-select-sm my-2" id="allPointsList"></select>
                  <i class="bi bi-plus-circle-fill text-blue-add ms-2 fs-5" onclick="addPointToReport();" title="<fmt:message key='common.add'/>"></i>
                </td>
            </tr>
            <tr>
              <td class="formLabelRequired align-middle my-2"><fmt:message key="dsList.show"/></td>
              <td class="formField">
                <table cellspacing="1" class="fs-7 text-center table table-light table-hover my-2">
                  <tbody id="reportPointsTableEmpty" style="display:none;">
                    <tr><th colspan="4"><fmt:message key="reports.noPoints"/></th></tr>
                  </tbody>
                  <tbody id="reportPointsTableHeaders" style="display:none;">
                    <tr class="align-middle smRowHeader">
                      <td><fmt:message key="reports.pointName"/></td>
                      <td><fmt:message key="reports.dataType"/></td>
                      <td><fmt:message key="reports.colour"/></td>
                      <td><fmt:message key="reports.consolidatedChart"/></td>
                      <td></td>
                    </tr>
                  </tbody>
                  <tbody id="reportPointsTable"></tbody>
                </table>
                <span id="pointsError" class="formError"></span>
              </td>
            </tr>
            
            <tr>
              <td class="formLabelRequired align-middle my-2"><fmt:message key="reports.events"/></td>
              <td class="formField">
                <select class="w-75 form-select form-select-sm my-2" id="includeEvents">
                  <option value="<c:out value="<%= ReportVO.EVENTS_NONE %>"/>"><fmt:message key="reports.events.none"/></option>
                  <option value="<c:out value="<%= ReportVO.EVENTS_ALARMS %>"/>"><fmt:message key="reports.events.alarms"/></option>
                  <option value="<c:out value="<%= ReportVO.EVENTS_ALL %>"/>"><fmt:message key="reports.events.all"/></option>
                </select>
              </td>
            </tr>
            
            <tr>
              <td class="formLabelRequired align-middle my-2"><fmt:message key="reports.comments"/></td>
              <td class="formField"><input class="form-check-input custom-checkbox my-2" type="checkbox" id="includeUserComments"/></td>
            </tr>
            
            <tr>
              <td class="formLabelRequired align-middle my-2"><fmt:message key="reports.dateRange"/></td>
              <td class="formField">
                <table>
                  <tr><td>
                    <input class="form-check-input custom-checkbox align-middle me-3" type="radio" name="dateRangeType" value="<c:out value="<%= ReportVO.DATE_RANGE_TYPE_RELATIVE %>"/>" id="drrel" 
                            checked="checked" onchange="updateDateRangeFields()"/><label 
                            for="drrel"><fmt:message key="reports.relative"/></label>
                  </td></tr>
                  <tr>
                    <td style="padding-left:40px;">
                      <table>
                        <tr>
                          <td valign="top" class="d-flex align-items-center justify-content-start">
                          <input class="form-check-input custom-checkbox align-middle me-3" type="radio" name="relativeType" onchange="updateDateRangeFields()" id="relprev" value="<c:out value="<%= ReportVO.RELATIVE_DATE_TYPE_PREVIOUS %>"/>" checked="checked"/>
                          <label for="relprev">
                          <fmt:message key="reports.previous"/></label></td>
                        <tr>
                          <td valign="top" class="d-flex align-items-center justify-content-start">
                            <input class="w-75 form-control form-control-sm mx-2" type="text" id="prevPeriodCount" class="formVeryShort"/>
                            <select class="form-select form-select-sm my-2" id="prevPeriodType">
                              <tag:timePeriodOptions min="true" h="true" d="true" w="true" mon="true" y="true"/>
                            </select><br/>
                            <span class="formError" id="previousPeriodCountError"></span>
                          </td>
                        </tr>
                        </tr>
                        <tr>
                          <td valign="top" class="d-flex align-items-center justify-content-start">
                            <input class="form-check-input custom-checkbox align-middle me-3" type="radio" name="relativeType" onchange="updateDateRangeFields()" id="relpast" value="<c:out value="<%= ReportVO.RELATIVE_DATE_TYPE_PAST %>"/>"/>
                            <label for="relpast">
                            <fmt:message key="reports.past"/></label>
                          </td>
                          <td valign="top" class="d-flex align-items-center justify-content-start">
                            <input class="w-75 form-control form-control-sm mx-2" type="text" id="pastPeriodCount" class="formVeryShort"/>
                            <select class="form-select form-select-sm my-2" id="pastPeriodType">
                              <tag:timePeriodOptions min="true" h="true" d="true" w="true" mon="true" y="true"/>
                            </select><br/>
                            <span class="formError" id="pastPeriodCountError"></span>
                          </td>
                        </tr>
                      </table>
                    </td>
                  </tr>
                  
                  <tr><td>
                    <input class="form-check-input custom-checkbox align-middle me-3" type="radio" name="dateRangeType" value="<c:out value="<%= ReportVO.DATE_RANGE_TYPE_SPECIFIC %>"/>" id="drspec" 
                            onchange="updateDateRangeFields()"/><label for="drspec"><fmt:message key="reports.specificDates"/></label>
                  </td></tr>
                  <tr>
                    <td class="text-center">
                      <table>
                        <tr>
                          <td></td>
                          <td align="center"><fmt:message key="common.tp.year"/></td>
                          <td align="center"><fmt:message key="common.tp.month"/></td>
                          <td align="center"><fmt:message key="common.tp.day"/></td>
                          <td align="center"><fmt:message key="common.tp.hour"/></td>
                          <td align="center"><fmt:message key="common.tp.minute"/></td>
                          <td></td>
                        </tr>
                        <tr>
                          <td><fmt:message key="common.dateRangeFrom"/></td>
                          <td><input class="form-control form-control-sm my-2" type="text" id="fromYear" class="formVeryShort"/></td>
                          <td><select class="form-select form-select-sm my-2" id="fromMonth"><tag:monthOptions/></select></td>
                          <td><select class="form-select form-select-sm my-2" id="fromDay"><tag:dayOptions/></select></td>
                          <td><select class="form-select form-select-sm my-2" id="fromHour"><tag:hourOptions/></select></td>
                          <td><select class="form-select form-select-sm my-2" id="fromMinute"><tag:minuteOptions/></select></td>
                          <td class="d-flex align-items-center justify-content-start text-center">
                            <input class="form-check-input custom-checkbox m-3" type="checkbox" name="fromNone" id="fromNone" onclick="updateDateRangeFields()"/><label for="fromNone">
                            <fmt:message key="common.inception"/></label>
                          </td>
                        </tr>
                        <tr>
                          <td><fmt:message key="common.dateRangeTo"/></td>
                          <td><input class="form-control form-control-sm my-2" type="text" id="toYear" class="formVeryShort"/></td>
                          <td><select class="form-select form-select-sm my-2" id="toMonth"><tag:monthOptions/></select></td>
                          <td><select class="form-select form-select-sm my-2" id="toDay"><tag:dayOptions/></select></td>
                          <td><select class="form-select form-select-sm my-2" id="toHour"><tag:hourOptions/></select></td>
                          <td><select class="form-select form-select-sm my-2" id="toMinute"><tag:minuteOptions/></select></td>
                          <td class="d-flex align-items-center justify-content-start">
                            <input class="form-check-input custom-checkbox m-3" type="checkbox" name="toNone" id="toNone" onclick="updateDateRangeFields()"/>
                            <label for="toNone"><fmt:message key="common.latest"/></label>
                          </td>
                        </tr>
                      </table>
                    </td>
                  </tr>
                </table>
              </td>
            </tr>
            
            <tr><td class="m-4" colspan="2"><hr class="border border-secondary w-100 my-4"/></td></tr>
            
            <tr>
              <td class="formLabelRequired align-middle my-2 text-uppercase"><fmt:message key="reports.schedule"/></td>
              <td class="formField">
                <input class="form-check-input custom-checkbox my-2" type="checkbox" id="schedule" onclick="updateScheduleFields();"/>
              </td>
            </tr>
            
            <tbody id="scheduleDetails">
              <tr>
                <td class="formLabelRequired align-middle my-2"><fmt:message key="reports.runEvery"/></td>
                <td class="formField">
                  <table cellpadding="0" cellspacing="0">
                    <tr><td>
                      <select class="w-50 form-select form-select-sm my-2" id="schedulePeriod" onchange="updateSchedulePeriodFields()">
                        <tag:timePeriodOptions h="true" d="true" w="true" mon="true" y="true" singular="true"/>
                        <option value="<c:out value="<%= ReportVO.SCHEDULE_CRON %>"/>"><fmt:message key="reports.cron"/></option>
                      </select>
                    </td></tr>
                    <tr><td class="d-flex align-items-center justify-content-start">
                      <fmt:message key="reports.runDelay"/>: <input class="w-25 form-control form-control-sm ms-2" type="text" id="runDelayMinutes" class="formVeryShort"/>
                      <div id="runDelayMinutesError" class="formError"></div>
                    </td></tr>
                    <tr><td class="d-flex align-items-center justify-content-start">
                      <fmt:message key="common.cronPattern"/>: <input class="w-50 form-control form-control-sm m-2" type="text" id="scheduleCron"/>
                      <tag:help id="cronPatterns"/><br/>
                      <span id="scheduleCronError" class="formError"></span>
                    </td></tr>
                  </table>
                </td>
              </tr>
            </tbody>
            
            <tr><td class="m-4" colspan="2"><hr class="border border-secondary w-100 my-4"/></td></tr>
            
            <tr>
              <td class="formLabelRequired align-middle my-2 text-uppercase"><fmt:message key="reports.emailReport"/></td>
              <td class="formField"><input class="form-check-input custom-checkbox my-2" type="checkbox" id="email" onclick="updateEmailFields();"/></td>
            </tr>
              
            <tbody id="emailDetails">
              <tr>
                <td class="formLabelRequired align-middle my-2"><fmt:message key="reports.includeTabular"/></td>
                <td class="formField"><input class="form-check-input custom-checkbox my-2" type="checkbox" id="includeData"/></td>
              </tr>
              
              <tr>
                <td class="formLabelRequired align-middle my-2"><fmt:message key="reports.zipData"/></td>
                <td class="formField"><input class="form-check-input custom-checkbox my-2" type="checkbox" id="zipData"/></td>
              </tr>
            </tbody>
            
            <tbody id="emailRecipBody"></tbody>
          </table>
        </div>
      </td>
    </tr>
  </table>
</tag:page>