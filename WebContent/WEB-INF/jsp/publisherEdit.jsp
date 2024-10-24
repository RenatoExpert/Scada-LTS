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
<tag:page dwr="PublisherEditDwr" onload="initPublisher">
  <script type="text/javascript">
    function savePublisher() {
        hide("nameMsg");
        hide("cacheWarningSizeMsg");
        hide("message");
        
        savePublisherImpl($get("name"), $get("xid"), $get("enabled"), $get("cacheWarningSize"),
                $get("changesOnly") == "true", $get("sendSnapshot"), $get("snapshotSendPeriods"),
                $get("snapshotSendPeriodType"));
    }
    
    function savePublisherCB(response) {
        if (response.hasMessages) {
            for (var i=0; i<response.messages.length; i++)
                showMessage(response.messages[i].contextKey +"Msg", response.messages[i].contextualMessage);
        } else {
            var errorMessages = document.getElementsByClassName("formError");
            for (var j = 0; j < errorMessages.length; j++) {
                errorMessages[j].innerHTML = '';
            }
            showMessage("message", "<fmt:message key="publisherEdit.saved"/>");
            showHttpSenderTest();
        }
    }
    
    function sendSnapshotChanged() {
        if ($get("sendSnapshot")) {
            setDisabled("snapshotSendPeriods", false);
            setDisabled("snapshotSendPeriodType", false);
        }
        else {
            setDisabled("snapshotSendPeriods", true);
            setDisabled("snapshotSendPeriodType", true);
        }
    }
    
    function initPublisher() {
        sendSnapshotChanged();
    }

    function showHttpSenderTest() {
        document.getElementById("httpSenderTest").style.visibility = "visible";
    }
  </script>
  
  <table  class="subPageHeader container">
    <tr>
      <td>
        <c:if test="${!empty publisherEvents}">
          <table class="right-box my-3">
            <tr><td class="smallTitle"><fmt:message key="publisherEdit.currentAlarms"/></td></tr>
            <c:forEach items="${publisherEvents}" var="event">
              <tr><td class="formError">
                <tag:eventIcon eventBean="${event}"/>
                <c:out value="${event.prettyActiveTimestamp}" />:
                <c:out value="${event.message}" />
              </td></tr>
            </c:forEach>
          </table>
        </c:if>
        
        <div id="message" class="formError" style="display:none;"></div>
        
        <div class="right-box my-3">
          <table>
            <div class="container">
            <div class="col-12 m-3">
              <div class="smallTitle">
                <%-- <i class="bi bi-broadcast-pin" title="<fmt:message key='common.edit'/>"></i> --%>
                <fmt:message key="publisherEdit.generalProperties"/>
                <tag:help id="generalPublisherProperties"/>
              </div>
            </div>
            </div>

            
            <div class="container">
              <div class="row">
                <div class="col-lg-6 col-12">
                  <div class="form-group row">
                    <label for="name" class="col-sm-3 col-form-label custom-padding-l"><fmt:message key="publisherEdit.name"/></label>
                    <div class="col-sm-8 my-2">
                      <input class="form-control form-control-sm" type="text" id="name" value="${publisher.name}"/>
                      <div id="nameMsg" class="formError" style="display:none;"></div>
                    </div>
                  </div>
                  <div class="form-group row">
                    <label for="xid" class="col-sm-3 col-form-label custom-padding-l"><fmt:message key="common.xid"/></label>
                    <div class="col-sm-8 my-2">
                      <input class="form-control form-control-sm" type="text" id="xid" value="${publisher.xid}"/>
                      <div id="xidMsg" class="formError" style="display:none;"></div>
                    </div>
                  </div>
                  <div class="form-group row">
                    <label for="enabled" class="col-sm-3 col-form-label custom-padding-l"><fmt:message key="common.enabled"/></label>
                    <div class="col-sm-5 my-2">
                      <input type="checkbox" class="form-check-input custom-checkbox" id="enabled" selectedValue="${publisher.enabled}"/>
                    </div>
                  </div>
                  <div class="form-group row">
                    <label for="caccol-sm-10heWarningSize" class="col-sm-4 col-form-label custom-padding-l"><fmt:message key="publisherEdit.cacheWarning"/></label>
                    <div class="col-sm-5 my-2">
                      <input class="form-control form-control-sm" type="text" id="cacheWarningSize" value="${publisher.cacheWarningSize}" class="formShort"/>
                      <div id="cacheWarningSizeMsg" class="formError" style="display:none;"></div>
                    </div>
                  </div>
                </div>
                
                <div class="col-lg-6 col-12">
                  <div class="form-group row">
                    <label for="changesOnly" class="col-sm-3 col-form-label custom-padding-l"><fmt:message key="publisherEdit.updateEvent"/></label>
                    <div class="col-sm-8 my-2">
                      <select id="changesOnly" class="form-select form-select-sm my-2" value="${publisher.changesOnly}">
                        <option value="false"><fmt:message key="publisherEdit.updateEvent.all"/></option>
                        <option value="true"><fmt:message key="publisherEdit.updateEvent.changes"/></option>
                      </select>
                    </div>
                  </div>
                  <div class="form-group row">
                    <label for="sendSnapshot" class="col-sm-6 col-form-label custom-padding-l"><fmt:message key="publisherEdit.snapshot"/></label>
                    <div class="col-sm-5 my-2">
                      <input type="checkbox" class="form-check-input custom-checkbox" id="sendSnapshot" onclick="sendSnapshotChanged()" selectedValue="${publisher.sendSnapshot}"/>
                    </div>
                  </div>
                  <div class="form-group row">
                    <label for="snapshotSendPeriods" class="col-sm-6 col-form-label custom-padding-l"><fmt:message key="publisherEdit.snapshotPeriod"/></label>
                    <div class="col-sm-5 my-2">
                      <input class="form-control form-control-sm" type="text" id="snapshotSendPeriods" value="${publisher.snapshotSendPeriods}" class="formShort"/>
                      <select class="form-select form-select-sm my-2" id="snapshotSendPeriodType" value="${publisher.snapshotSendPeriodType}">
                        <tag:timePeriodOptions sst="true" s="true" min="true" h="true"/>
                      </select>
                      <div id="snapshotSendPeriodsMsg" class="formError" style="display:none;"></div>
                    </div>
                  </div>
                </div>
              </div>
            </div>

          </table>
        </div>
        
        <div>
          <c:choose>
            <c:when test="${publisher.type.id == applicationScope['constants.PublisherVO.Types.HTTP_SENDER']}">
              <%@ include file="/WEB-INF/jsp/publisherEdit/editHttpSender.jsp" %>
            </c:when>
            <c:when test="${publisher.type.id == applicationScope['constants.PublisherVO.Types.PACHUBE']}">
              <%@ include file="/WEB-INF/jsp/publisherEdit/editPachube.jsp" %>
            </c:when>
            <c:when test="${publisher.type.id == applicationScope['constants.PublisherVO.Types.PERSISTENT']}">
              <%@ include file="/WEB-INF/jsp/publisherEdit/editPersistent.jsp" %>
            </c:when>
          </c:choose>
        </div>
      </td>
    </tr>
    
    <tr><td>&nbsp;</td></tr>
    
    <tr>
      <td align="center">
        <button type="button" class="btn btn-primary custom-btn-blue mx-2" name="savePublisher" onclick="savePublisher()"><fmt:message key="common.save"/></button>
        <button type="button" class="btn btn-primary custom-btn-blue mx-2" name="common.cancel" onclick="window.location='publishers.shtm'"><fmt:message key="common.cancel"/></button>
      </td>
    </tr>
  </table>
</tag:page>