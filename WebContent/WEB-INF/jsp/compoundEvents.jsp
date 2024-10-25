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
<c:set var="NEW_ID"><%= Common.NEW_ID %></c:set>

<tag:page dwr="CompoundEventsDwr" onload="init">
  <script type="text/javascript">
    function init() {
        CompoundEventsDwr.getInitData(function(data) {
            // List the compound events.
            for (var i=0; i<data.compoundEvents.length; i++) {
                appendCompoundEvent(data.compoundEvents[i].id);
                updateCompoundEvent(data.compoundEvents[i]);
            }
            
            // Create the tree of event detectors
            var i, j;
            var dp, et;
            var pointNode;
            
            var pointRoot = dojo.widget.manager.getWidgetById('rootPoint');
            for (i=0; i<data.dataPoints.length; i++) {
                dp = data.dataPoints[i];
                pointNode = dojo.widget.createWidget("TreeNode", {title: "<i class='bi bi-search'></i> " + dp.name});
                pointRoot.addChild(pointNode);
                
                for (j=0; j<dp.eventTypes.length; j++) {
                    et = dp.eventTypes[j];
                    createEventTypeNode("ped"+ et.typeRef2, et, pointNode);
                }
            }
            pointRoot.expand();
            
            var scheduledRoot = dojo.widget.manager.getWidgetById('rootScheduled');
            for (i=0; i<data.scheduledEvents.length; i++) {
                et = data.scheduledEvents[i];
                createEventTypeNode("sch"+ et.typeRef1, et, scheduledRoot);
            }
            scheduledRoot.expand();
            
            // Default the selection of the parameter was provided.
            <c:if test="${!empty param.cedid}">
              showCompoundEvent(${param.cedid});
            </c:if>
        });
        
        dojo.event.topic.subscribe("eventTypeTree/titleClick", new TreeClickHandler(), 'handle');
    }
    
    var editingCompoundEvent;
    
    function createEventTypeNode(widgetId, eventType, parent) {
        var node = dojo.widget.createWidget("TreeNode", {
                title: "<i id='"+ widgetId +"Img'></i> "+ eventType.description +" ("+ eventType.eventDetectorKey +")",
                widgetId: widgetId,
                object: eventType.eventDetectorKey
        });
        parent.addChild(node);
        setAlarmLevelImg(eventType.alarmLevel, $(widgetId +"Img"));
    }
    
    var TreeClickHandler = function() {
        this.handle = function(message) {
            var widget = message.source;
            var wid = widget.widgetId;
            if (wid.startsWith("ped") || wid.startsWith("sch"))
                insertText(widget.object);
        }
    }
    
    function showCompoundEvent(cedId) {
        if (editingCompoundEvent)
            stopImageFader($("ced"+ editingCompoundEvent.id +"Img"));
        CompoundEventsDwr.getCompoundEvent(cedId, function(ced) {
            if (!editingCompoundEvent) {
                show($("compoundEventDetails"));
                show($("eventTypes"));
            }
            editingCompoundEvent = ced;
            
            $set("xid", ced.xid);
            $set("name", ced.name);
            $set("alarmLevel", ced.alarmLevel);
            $set("rtn", ced.returnToNormal);
            $set("condition", ced.condition);
            $set("disabled", ced.disabled);
            
            setUserMessage();
        });
        startImageFader($("ced"+ cedId +"Img"));
        
        if (cedId == ${NEW_ID})
            hide($("deleteCompoundEventImg"));
        else
            show($("deleteCompoundEventImg"));
    }
    
    function saveCompoundEvent() {
        setUserMessage();
        hideContextualMessages("compoundEventDetails")
        
        CompoundEventsDwr.saveCompoundEvent(editingCompoundEvent.id, $get("xid"), $get("name"), $get("alarmLevel"),
                $get("rtn"), $get("condition"), $get("disabled"), function(response) {
            if (response.hasMessages) {
                showDwrMessages(response.messages);
                if (response.range)
                    setSelectionRange($("condition"), response.data.from, response.data.to);
            }
            else {
                if (editingCompoundEvent.id == ${NEW_ID}) {
                    stopImageFader($("ced"+ editingCompoundEvent.id +"Img"));
                    editingCompoundEvent.id = response.data.cedId;
                    appendCompoundEvent(editingCompoundEvent.id);
                    startImageFader($("ced"+ editingCompoundEvent.id +"Img"));
                    setUserMessage("<fmt:message key="compoundDetectors.cedAdded"/>");
                    show($("deleteCompoundEventImg"));
                }
                else
                    setUserMessage("<fmt:message key="compoundDetectors.cedSaved"/>");
                
                if (response.data.warning)
                    setUserMessage(response.data.warning);
                    
                CompoundEventsDwr.getCompoundEvent(editingCompoundEvent.id, updateCompoundEvent)
            }
        });
    }
    
    function setUserMessage(message) {
        if (message) {
            show($("userMessage"));
            $("userMessage").innerHTML = message;
        }
        else
            hide($("userMessage"));
    }
    
    function appendCompoundEvent(cedId) {
        createFromTemplate("ced_TEMPLATE_", cedId, "compoundEventsTable");
    }
    
    function updateCompoundEvent(ced) {
        $("ced"+ ced.id +"Name").innerHTML = ced.name;
        setCompoundEventImg(ced.disabled, $("ced"+ ced.id +"Img"));
    }
    
    function deleteCompoundEvent() {
        CompoundEventsDwr.deleteCompoundEvent(editingCompoundEvent.id, function() {
            stopImageFader($("ced"+ editingCompoundEvent.id +"Img"));
            $("compoundEventsTable").removeChild($("ced"+ editingCompoundEvent.id));
            hide($("compoundEventDetails"));
            hide($("eventTypes"));
            editingCompoundEvent = null;
        });
    }
    
    function updateAlarmLevelImage(alarmLevel) {
        setAlarmLevelImg(alarmLevel, $("alarmLevelImg"));
    }
    
    function validate() {
        setUserMessage();
        CompoundEventsDwr.validateCondition($get("condition"), function(response) {
            if (response.hasMessages) {
                showDwrMessages(response.messages);
                if (response.data.range)
                    setSelectionRange($("condition"), response.data.from, response.data.to);
            }
            else
                setUserMessage("<fmt:message key="compoundDetectors.cedValidated"/>");
        });
    }
    
    function insertText(text) {
        insertIntoTextArea($("condition"), text);
    }
  </script>
  
  <table class="subPageHeader  container">
    <tr>
    <td class="d-flex align-items-start">
        <div class="left-menu">
        <div class="d-flex justify-content-between align-items-center mb-3">
        <div>
          <span class="smallTitle"><fmt:message key="compoundDetectors.compoundEventDetectors"/></span>
          <tag:help id="compoundEventDetectors"/>
        </div>
        <div>
            <i class="bi bi-plus-circle-fill text-blue-add align-middle ms-3 fs-5" title="<fmt:message key='common.add'/>" id="ced${NEW_ID}Img" onclick="showCompoundEvent(${NEW_ID})"></i>
                      <%-- <span style="font-size: 16px;">
                      <sst:i18n key='common.add' escapeDQuotes='true'/>
                      </span> --%>
        </div>
        </div>
        <div class="top-row-d-flex justify-content-between container py-2 box mb-3">
          <table id="compoundEventsTable">
            <tbody id="ced_TEMPLATE_" onclick="showCompoundEvent(getMangoId(this))" class="ptr" style="display:none;">
              <tr>
                <td>
                    <i id="ced_TEMPLATE_Img" class="bi bi-bell align-middle ms-3 fs-5" title="<fmt:message key='compoundDetectors.compoundEventDetector'/>"></i>
                </td>
                <td class="text-uppercase fs-7" id="ced_TEMPLATE_Name"></td>
              </tr></tbody>
          </table>
        </div>
        </div>
      </td>
  
      <td valign="top" style="display:none;" id="compoundEventDetails">
        <div class="right-box">
            <div class="d-flex justify-content-between container py-2 box mb-3">
              <div>
                <span class="smallTitle"><fmt:message key="compoundDetectors.details"/></span>
              </div>
              <div class="d-flex justify-content-between align-items-center">
                <i class="bi bi-floppy2-fill text-blue-add  me-2 fs-5" onclick="saveCompoundEvent();" title="<fmt:message key='common.save'/>"></i>
                  <span style="font-size: 16px;">
                  <sst:i18n key='common.save' escapeDQuotes='true'/>
                  </span>
                <i id="deleteCompoundEventImg" class="bi bi-trash  text-danger ms-2 me-2 fs-5" onclick="deleteCompoundEvent();" title="<fmt:message key='common.delete'/>">
                  <span style="font-size: 16px; color: var(--slts-color-primary-text);">
                  <sst:i18n key='common.delete' escapeDQuotes='true'/>
                  </span></i>
              </div>
          </div>
  
          <table class="m-4">
            <div class="d-flex justify-content-center align-items-center">
              <div class="col-sm-3 col-form-label custom-padding-l my-2 fs-6"><fmt:message key="common.xid"/></div>
              <div class="formField col-sm-5"><input class="form-control form-control-sm my-2"type="text" id="xid"/></div>
            </div>
            
            <div class="d-flex justify-content-center align-items-center">
              <div class="col-sm-3 col-form-label custom-padding-l my-2 fs-6"><fmt:message key="compoundDetectors.name"/></div>
              <div class="formField col-sm-5"><input class="form-control form-control-sm my-2" type="text" id="name"/></div>
            </div>
            
            <div class="d-flex justify-content-center align-items-center">
              <div class="col-sm-3 col-form-label custom-padding-l my-2 fs-6"><fmt:message key="common.alarmLevel"/></div>
              <div class="formField col-sm-5 col-sm-5">
                <select class="form-select form-select-sm my-2" id="alarmLevel" onchange="updateAlarmLevelImage(this.value)">
                  <tag:alarmLevelOptions/>
                </select>
                <tag:img id="alarmLevelImg" png="flag_green" title="common.alarmLevel.none" style="display:none;"/>
              </div>
            </div>
            
            <div class="d-flex justify-content-center align-items-center">
              <div class="col-sm-3 col-form-label custom-padding-l my-2 fs-6"><fmt:message key="common.rtn"/></div>
              <div class="formField col-sm-5 col-sm-5"><input class="form-check-input custom-checkbox my-2" type="checkbox" id="rtn"/></div>
            </div>
            
            <div class="d-flex justify-content-center align-items-center">
              <div class="col-sm-3 col-form-label custom-padding-l my-2 fs-6">
                <fmt:message key="compoundDetectors.condition"/>
                <i class="bi bi-check-circle-fill text-success  me-2 fs-5" onclick="validate();" title="<fmt:message key='compoundDetectors.validate'/>"></i><br/>
                <br/>
                <div class="d-flex flex-column align-items-center">
                <a href="#" onclick="insertText(' && '); return false;"><fmt:message key="compoundDetectors.and"/></a><br/>
                <a href="#" onclick="insertText(' || '); return false;"><fmt:message key="compoundDetectors.or"/></a><br/>
                <a href="#" onclick="insertText('!'); return false;"><fmt:message key="compoundDetectors.not"/></a><br/>
                </div>
              </div>
              <div class="formField col-sm-5 col-sm-5"><textarea class="form-control mb-3" rows="10" cols="60" id="condition"></textarea></div>
            </div>
            
            <div class="d-flex justify-content-center align-items-center">
              <div class="col-sm-3 col-form-label custom-padding-l my-2 fs-6"><fmt:message key="common.disabled"/></div>
              <div class="formField col-sm-5 col-sm-5"><input class="form-check-input custom-checkbox my-2" type="checkbox" id="disabled"/></div>
            </div>
              <tr><div class="m-4" colspan="2"><hr class="border border-secondary w-100 my-4"/></div></tr>
              <tr>
                <div valign="top" style="display:none;" id="eventTypes">
                <div class="m-3">
                  <div class="right-box">
                    <span class="smallTitle"><fmt:message key="compoundDetectors.eventTypes"/></span>
                    <div dojoType="TreeBasicController" widgetId="controller"></div>
                    <div id="tree">
                      <div dojoType="Tree" widgetId="eventTypeTree" listeners="controller" toggle="wipe">
                        <div dojoType="TreeNode" title="<fmt:message key="compoundDetectors.pointEventDetector"/>" widgetId="rootPoint"></div>
                        <div dojoType="TreeNode" title="<fmt:message key="scheduledEvents.ses"/>" widgetId="rootScheduled"></div>
                      </div>
                    </div>
                  </div>
                </div>
                </div>
              </tr>
          </table>
          <table>
            <tr>
              <td colspan="2" id="userMessage" class="formError" style="display:none;"></td>
            </tr>
          </table>
        </div>
      </td>
    </tr>
  </table>
</tag:page>