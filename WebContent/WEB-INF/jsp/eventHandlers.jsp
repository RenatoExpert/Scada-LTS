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
<%@page import="com.serotonin.mango.vo.event.EventHandlerVO"%>
<%@page import="com.serotonin.mango.DataTypes"%>
<c:set var="NEW_ID"><%= Common.NEW_ID %></c:set>

<tag:page dwr="EventHandlersDwr,ScriptsDwr" js="emailRecipients" onload="init">
  <script>
    function init() {
    	ScriptsDwr.getScripts(getScriptsCB);
        EventHandlersDwr.getInitData(initCB);
        
        var tree = dojo.widget.manager.getWidgetById('eventTypeTree');
        dojo.event.topic.subscribe("eventTypeTree/titleClick", new TreeClickHandler(), 'handle');
    }

	function getScriptsCB(scripts) {
		var activeScriptList = $("activeScriptCommand");
		var inactiveScriptList = $("inactiveScriptCommand");
        dwr.util.removeAllOptions("activeScriptCommand");
        dwr.util.removeAllOptions("inactiveScriptCommand");

        activeScriptList.options[0] = new Option("", -1);
        inactiveScriptList.options[0] = new Option("", -1);
        
        for (var i=0; i<scripts.length; i++) {
            sc = scripts[i];
            activeScriptList.options[activeScriptList.options.length] = new Option(sc.name, sc.id);
            inactiveScriptList.options[inactiveScriptList.options.length] = new Option(sc.name, sc.id);
        }
	}
    
    var allPoints;
    var defaultHandlerId;
    var emailRecipients;
    var smsRecipients;
    var escalRecipients;
    var inactiveRecipients;
    
    function initCB(data) {
        <c:if test="${!empty param.ehid}">
          defaultHandlerId = ${param.ehid};
        </c:if>
    
        var i, j, k;
        var dp, ds, p, et;
        var pointNode, dataSourceNode, publisherNode, etNode, wid;
        
        allPoints = data.allPoints;
        
        emailRecipients = new mango.erecip.EmailRecipients("emailRecipients",
                "<sst:i18n key="eventHandlers.recipTestEmailMessage" escapeDQuotes="true"/>",
                data.mailingLists, data.users);
        emailRecipients.write("emailRecipients", "emailRecipients", null,
            "<sst:i18n key="eventHandlers.emailRecipients" escapeDQuotes="true"/>");
        smsRecipients = new mango.erecip.EmailRecipients("smsRecipients",
                "<sst:i18n key="eventHandlers.recipTestEmailMessage" escapeDQuotes="true"/>",
                data.mailingLists, data.users);
        smsRecipients.write("smsRecipients", "smsRecipients", "smsRecipients",
        		"<sst:i18n key="eventHandlers.emailRecipients" escapeDQuotes="true"/>");
        
        escalRecipients = new mango.erecip.EmailRecipients("escalRecipients",
                "<sst:i18n key="eventHandlers.escalTestEmailMessage" escapeDQuotes="true"/>",
                data.mailingLists, data.users);
        escalRecipients.write("escalRecipients", "escalRecipients", "escalationAddresses2",
        		"<sst:i18n key="eventHandlers.escalRecipients" escapeDQuotes="true"/>");
        
        inactiveRecipients = new mango.erecip.EmailRecipients("inactiveRecipients",
                "<sst:i18n key="eventHandlers.inactiveTestEmailMessage" escapeDQuotes="true"/>",
                data.mailingLists, data.users);
        inactiveRecipients.write("inactiveRecipients", "inactiveRecipients", "inactiveAddresses2",
        		"<sst:i18n key="eventHandlers.inactiveRecipients" escapeDQuotes="true"/>");
        
        var pointRoot = dojo.widget.manager.getWidgetById('rootPoint');
        for (i=0; i<data.dataPoints.length; i++) {
            dp = data.dataPoints[i];
            pointNode = dojo.widget.createWidget("TreeNode", {
                    title: "<i class='bi bi-search text-blue-add align-middle mx-2 fs-5'></i> " + dp.name,
                    object: dp
            });
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

        var compoundRoot = dojo.widget.manager.getWidgetById('rootCompound');
        for (i=0; i<data.compoundEvents.length; i++) {
            et = data.compoundEvents[i];
            createEventTypeNode("ced"+ et.typeRef1, et, compoundRoot);
        }
        compoundRoot.expand();

        var dataSourceRoot = dojo.widget.manager.getWidgetById('rootDataSource');
        for (i=0; i<data.dataSources.length; i++) {
            ds = data.dataSources[i];
            dataSourceNode = dojo.widget.createWidget("TreeNode", {
                    title: "<i class='bi bi-database-add text-blue-add align-middle mx-2 fs-5'></i> " + ds.name,
                    object: ds
            });
            dataSourceRoot.addChild(dataSourceNode);

            for (j=0; j<ds.eventTypes.length; j++) {
                et = ds.eventTypes[j];
                createEventTypeNode("dse"+ et.typeRef1 +"/"+ et.typeRef2, et, dataSourceNode);
            }
        }
        if (data.publishers) {
            var publisherRoot = dojo.widget.manager.getWidgetById('rootPublisher');
            for (i=0; i<data.publishers.length; i++) {
                p = data.publishers[i];
                publisherNode = dojo.widget.createWidget("TreeNode", {
                                        title: "<i class='bi bi-upload text-blue-add align-middle mx-2 fs-5'></i> " + p.name,
                                        object: p
                                });
                publisherRoot.addChild(publisherNode);

                for (j=0; j<p.eventTypes.length; j++) {
                    et = p.eventTypes[j];
                    createEventTypeNode("pube"+ et.typeRef1 +"/"+ et.typeRef2, et, publisherNode);
                }
            }
        }

        if (data.maintenanceEvents) {
            var maintenanceRoot = dojo.widget.manager.getWidgetById('rootMaintenance');
            for (i=0; i<data.maintenanceEvents.length; i++) {
                et = data.maintenanceEvents[i];
                createEventTypeNode("maint"+ et.typeRef1, et, maintenanceRoot);
            }
        }

        if (data.systemEvents) {
            var systemRoot = dojo.widget.manager.getWidgetById('rootSystem');
            for (i=0; i<data.systemEvents.length; i++) {
                et = data.systemEvents[i];
                createEventTypeNode("sys"+ et.typeRef1, et, systemRoot);
            }
        }

        if (data.auditEvents) {
            var auditRoot = dojo.widget.manager.getWidgetById('rootAudit');
            for (i=0; i<data.auditEvents.length; i++) {
                et = data.auditEvents[i];
                createEventTypeNode("aud"+ et.typeRef1, et, auditRoot);
            }
        }

        hide("loadingImg");
        show("tree");
        removeBackgroundImage(); // Remove the background image from the tree nodes

        // Default the selection of the parameter was provided.
        if (selectedHandlerNode) {
            selectedHandlerNode.onTitleClick();
            var parent = selectedHandlerNode.parent;
            while (parent && parent.expand) {
                parent.expand();
                parent = parent.parent;
            }
        }
        defaultHandlerId = null;
    }

    function createEventTypeNode(widgetId, eventType, parent) {
        var node = dojo.widget.createWidget("TreeNode", {
                title: "<a id='"+ widgetId +"a'/> "+ eventType.description,
                widgetId: widgetId,
                object: eventType
        });
        parent.addChild(node);
        setAlarmLevelImg(eventType.alarmLevel, $(widgetId +"a"));
        addHandlerNodes(eventType.handlers, node);
    }

    function addHandlerNodes(handlers, parent) {
        for (var i=0; i<handlers.length; i++)
            parent.addChild(createHandlerNode(handlers[i]));
    }

    function createHandlerNode(handler) {
        var img = "class='bi bi-hammer text-blue-add align-middle mx-2 fs-6'";
        if (handler.handlerType == <c:out value="<%= EventHandlerVO.TYPE_EMAIL %>"/>)
            img = "class='bi bi-envelope text-blue-add align-middle mx-2 fs-6'";
        else if (handler.handlerType == <c:out value="<%= EventHandlerVO.TYPE_PROCESS %>"/>)
            img = "class='bi bi-terminal text-blue-add align-middle mx-2 fs-6'";

        var node = dojo.widget.createWidget("TreeNode", {
                title: "<a "+ img +"/> <span id='"+ handler.id +"Msg'>"+ handler.message +"</span>",
                widgetId: "h"+ handler.id,
                object: handler
        });

        if (handler.id == defaultHandlerId)
            selectedHandlerNode = node;
        

        removeBackgroundImage(); // Remove the background image from the tree nodes

        return node;
    }

    var selectedEventTypeNode;
    var selectedHandlerNode;

    var TreeClickHandler = function() {
        this.handle = function(message) {
            var widget = message.source;
            var wid = widget.widgetId;
            if (wid.startsWith("ped") || wid.startsWith("sch") || wid.startsWith("ced") ||
                    wid.startsWith("dse") || wid.startsWith("pube") || wid.startsWith("sys") ||
                    wid.startsWith("aud") || wid.startsWith("maint")) {
                selectedEventTypeNode = widget;
                selectedHandlerNode = null;
                showHandlerEdit();
            }
            else if (wid.startsWith("h")) {
                selectedHandlerNode = widget;
                selectedEventTypeNode = selectedHandlerNode.parent;
                showHandlerEdit();
            }
            else
                hide("handlerEditDiv");
        }
    }

    function showHandlerEdit() {
    	show("handlerEditDiv");
        setUserMessage("");
        // Set the target points.
        var pointSelect = $("targetPointSelect");
        dwr.util.removeAllOptions(pointSelect);
        for (var i=0; i<allPoints.length; i++) {
            dp = allPoints[i];
            if (dp.settable)
                pointSelect.options[pointSelect.options.length] = new Option(dp.name, dp.id);
        }
        if (selectedHandlerNode) {
            $("saveImg").src = "images/save.png";
            show("deleteImg");

            // Put values from the handler object into the input controls.
            var handler = selectedHandlerNode.object;
            $set("handlerTypeSelect", handler.handlerType);
            $("handlerTypeSelect").disabled = true;
            $set("xid", handler.xid);
            $set("alias", handler.alias);
            $set("disabled", handler.disabled);
            if (handler.handlerType == <c:out value="<%= EventHandlerVO.TYPE_SET_POINT %>"/>) {
                $set("targetPointSelect", handler.targetPointId);
                $set("activeAction", handler.activeAction);
                $set("inactiveAction", handler.inactiveAction);
            }
            else if (handler.handlerType == <c:out value="<%= EventHandlerVO.TYPE_EMAIL %>"/>) {
                emailRecipients.updateRecipientList(handler.activeRecipients);
                $set("sendEscalation", handler.sendEscalation);
                $set("escalationDelayType", handler.escalationDelayType);
                $set("escalationDelay", handler.escalationDelay);
                escalRecipients.updateRecipientList(handler.escalationRecipients);
                $set("sendInactive", handler.sendInactive);
                $set("inactiveOverride", handler.inactiveOverride);
                inactiveRecipients.updateRecipientList(handler.inactiveRecipients);
            }
            else if (handler.handlerType == <c:out value="<%= EventHandlerVO.TYPE_SMS %>"/>) {
                smsRecipients.updateRecipientList(handler.activeRecipients);
            }
            else if (handler.handlerType == <c:out value="<%= EventHandlerVO.TYPE_PROCESS %>"/>) {
                $set("activeProcessCommand", handler.activeProcessCommand);
                $set("inactiveProcessCommand", handler.inactiveProcessCommand);
            } else if (handler.handlerType == <c:out value="<%= EventHandlerVO.TYPE_SCRIPT %>"/>) {
                $set("activeScriptCommand", handler.activeScriptCommand);
                $set("inactiveScriptCommand", handler.inactiveScriptCommand);
            }
        }
        else {
            $("saveImg").src = "images/save_add.png";
            hide("deleteImg");
            $("handlerTypeSelect").disabled = false;

            // Clear values that may be left over from another handler.
            $set("xid", "");
            $set("alias", "");
            $set("disabled", false);
            $set("activeAction", <c:out value="<%= EventHandlerVO.SET_ACTION_NONE %>"/>);
            $set("inactiveAction", <c:out value="<%= EventHandlerVO.SET_ACTION_NONE %>"/>);
            $set("sendEscalation", false);
            $set("escalationDelayType", <c:out value="<%= Common.TimePeriods.HOURS %>"/>);
            $set("escalationDelay", 1);
            $set("sendInactive", false);
            $set("inactiveOverride", false);
            $set("activeProcessCommand", "");
            $set("inactiveProcessCommand", "");
            $set("activeScriptCommand", -1);
            $set("inactiveScriptCommand", -1);
            // Clear the recipient lists.
            emailRecipients.updateRecipientList();
            smsRecipients.updateRecipientList();
            escalRecipients.updateRecipientList();
            inactiveRecipients.updateRecipientList();

        }
        // Set the use source value checkbox.
        handlerTypeChanged();
        activeActionChanged();
        inactiveActionChanged();
        targetPointSelectChanged();
        sendEscalationChanged();
        sendInactiveChanged();

    }

    var currentHandlerEditor;
    function handlerTypeChanged() {
        setUserMessage("");
        var handlerId = $get("handlerTypeSelect");

        if (currentHandlerEditor) {
        	hide(currentHandlerEditor);
        	hide($(currentHandlerEditor.id +"Img"));
        	if(currentHandlerEditor.id === "handler<c:out value="<%= EventHandlerVO.TYPE_SMS %>"/>") {
        	    hide($(currentHandlerEditor.id + "Help"));
        	}
        }
        currentHandlerEditor = $("handler"+ handlerId);
        show(currentHandlerEditor);
        show($(currentHandlerEditor.id +"Img"));
        if(currentHandlerEditor.id === "handler<c:out value="<%= EventHandlerVO.TYPE_SMS %>"/>") {
            show($(currentHandlerEditor.id + "Help"));
        }
        console.log("handler<c:out value="<%= EventHandlerVO.TYPE_SMS %>"/>");
    }

    function targetPointSelectChanged() {
        var selectControl = $("targetPointSelect");

        // Make sure there are points in the list.
        if (selectControl.options.length == 0)
            return;

        // Get the content for the value to set section.
        var targetPointId = selectControl.value;
        var activeValueStr = "";
        var inactiveValueStr = "";
        if (selectedHandlerNode) {
            activeValueStr = selectedHandlerNode.object.activeValueToSet;
            inactiveValueStr = selectedHandlerNode.object.inactiveValueToSet;
        }
        EventHandlersDwr.createSetValueContent(targetPointId, activeValueStr, "Active",
                function(content) { $("activeValueToSetContent").innerHTML = content; });
        EventHandlersDwr.createSetValueContent(targetPointId, inactiveValueStr, "Inactive",
                function(content) { $("inactiveValueToSetContent").innerHTML = content; });

        // Update the source point lists.
        var targetDataTypeId = getPoint(targetPointId).dataType;
        var activeSourceSelect = $("activePointId");
        dwr.util.removeAllOptions(activeSourceSelect);
        var inactiveSourceSelect = $("inactivePointId");
        dwr.util.removeAllOptions(inactiveSourceSelect);
        for (var i=0; i<allPoints.length; i++) {
            dp = allPoints[i];
            if (dp.id != targetPointId && dp.dataType == targetDataTypeId) {
                activeSourceSelect.options[activeSourceSelect.options.length] = new Option(dp.name, dp.id);
                inactiveSourceSelect.options[activeSourceSelect.options.length] = new Option(dp.name, dp.id);
            }
        }
        if (selectedHandlerNode) {
            $set(activeSourceSelect, selectedHandlerNode.object.activePointId);
            $set(inactiveSourceSelect, selectedHandlerNode.object.inactivePointId);
        }
    }

    function activeActionChanged() {
        var action = $get("activeAction");
        if (action == <c:out value="<%= EventHandlerVO.SET_ACTION_POINT_VALUE %>"/>) {
        	show("activePointIdRow");
            hide("activeValueToSetRow");
        }
        else if (action == <c:out value="<%= EventHandlerVO.SET_ACTION_STATIC_VALUE %>"/>) {
        	hide("activePointIdRow");
        	show("activeValueToSetRow");
        }
        else {
        	hide("activePointIdRow");
        	hide("activeValueToSetRow");
        }
    }

    function inactiveActionChanged() {
        var action = $get("inactiveAction");
        if (action == <c:out value="<%= EventHandlerVO.SET_ACTION_POINT_VALUE %>"/>) {
        	show("inactivePointIdRow");
            hide("inactiveValueToSetRow");
        }
        else if (action == <c:out value="<%= EventHandlerVO.SET_ACTION_STATIC_VALUE %>"/>) {
        	hide("inactivePointIdRow");
        	show("inactiveValueToSetRow");
        }
        else {
        	hide("inactivePointIdRow");
        	hide("inactiveValueToSetRow");
        }
    }

    function sendEscalationChanged() {
        if ($get("sendEscalation")) {
        	show("escalationAddresses1");
            show("escalationAddresses2");
        }
        else {
        	hide("escalationAddresses1");
        	hide("escalationAddresses2");
        }
    }

    function getPoint(id) {
        return getElement(allPoints, id);
    }

    function saveHandler() {
    	startImageFader("saveImg");
        setUserMessage();
        hideContextualMessages("scheduledEventDetails")
        hideGenericMessages("genericMessages")

        var handlerId = ${NEW_ID};
        if (selectedHandlerNode)
            handlerId = selectedHandlerNode.object.id;

        // Do some validation.
        var handlerType = $get("handlerTypeSelect");
        var xid = $get("xid");
        var alias = $get("alias");
        var disabled = $get("disabled");
        if (handlerType == <c:out value="<%= EventHandlerVO.TYPE_EMAIL %>"/>) {
            var emailList = emailRecipients.createRecipientArray();
            var escalList = escalRecipients.createRecipientArray();
            var inactiveList = inactiveRecipients.createRecipientArray();
            EventHandlersDwr.saveEmailEventHandler(selectedEventTypeNode.object.typeId,
                    selectedEventTypeNode.object.typeRef1, selectedEventTypeNode.object.typeRef2, handlerId, xid, alias,
                    disabled, emailList, $get("sendEscalation"), $get("escalationDelayType"), $get("escalationDelay"),
                    escalList, $get("sendInactive"), $get("inactiveOverride"), inactiveList, saveEventHandlerCB);
        }
        else if (handlerType == <c:out value="<%= EventHandlerVO.TYPE_SMS %>"/>) {
            var smsList = smsRecipients.createRecipientArray();
            EventHandlersDwr.saveSmsEventHandler(selectedEventTypeNode.object.typeId,
                    selectedEventTypeNode.object.typeRef1, selectedEventTypeNode.object.typeRef2, handlerId, xid, alias, disabled, smsList, saveEventHandlerCB);
        }
        else if (handlerType == <c:out value="<%= EventHandlerVO.TYPE_SET_POINT %>"/>) {
            EventHandlersDwr.saveSetPointEventHandler(selectedEventTypeNode.object.typeId,
                    selectedEventTypeNode.object.typeRef1, selectedEventTypeNode.object.typeRef2, handlerId, xid, alias,
                    disabled, $get("targetPointSelect"), $get("activeAction"), $get("setPointValueActive"),
                    $get("activePointId"), $get("inactiveAction"), $get("setPointValueInactive"),
                    $get("inactivePointId"), saveEventHandlerCB);
        }
        else if (handlerType == <c:out value="<%= EventHandlerVO.TYPE_PROCESS %>"/>) {
            EventHandlersDwr.saveProcessEventHandler(selectedEventTypeNode.object.typeId,
                    selectedEventTypeNode.object.typeRef1, selectedEventTypeNode.object.typeRef2, handlerId, xid,
                    alias, disabled, $get("activeProcessCommand"), $get("inactiveProcessCommand"), saveEventHandlerCB);
        }
        else if (handlerType == <c:out value="<%= EventHandlerVO.TYPE_SCRIPT %>"/>) {
            EventHandlersDwr.saveScriptEventHandler(selectedEventTypeNode.object.typeId,
                    selectedEventTypeNode.object.typeRef1, selectedEventTypeNode.object.typeRef2, handlerId, xid,
                    alias, disabled, $get("activeScriptCommand"), $get("inactiveScriptCommand"), saveEventHandlerCB);
        }
    }

    function saveEventHandlerCB(response) {
    	stopImageFader("saveImg");

        if (response.hasMessages)
            showDwrMessages(response.messages, $("genericMessages"));
        else {
            var handler = response.data.handler;
            setUserMessage("<fmt:message key="eventHandlers.saved"/>");
            if (!selectedHandlerNode) {
                selectedHandlerNode = createHandlerNode(handler);
                selectedEventTypeNode.addChild(selectedHandlerNode);
                selectedEventTypeNode.expand();
                selectedHandlerNode.onTitleClick();
            }
            else
                $set(handler.id +"Msg", handler.message);

            selectedHandlerNode.object = handler;
        }
    }

    function deleteHandler() {
        EventHandlersDwr.deleteEventHandler(selectedHandlerNode.object.id);
        selectedEventTypeNode.removeNode(selectedHandlerNode);
        hide("handlerEditDiv");
    }

    function setUserMessage(msg) {
        showMessage("userMessage", msg);
    }

    function testProcessCommand(nodeId) {
    	EventHandlersDwr.testProcessCommand($get(nodeId), function(msg) {
    		if (msg)
    			alert(msg);
    	});
    }

    function testScriptCommand(nodeId) {
    	alert('Not implemented.');
    }

    function sendInactiveChanged() {
        if ($get("sendInactive")) {
            show("inactiveAddresses1");
            inactiveOverrideChanged();
        }
        else {
            hide("inactiveAddresses1");
            hide("inactiveAddresses2");
        }
    }

    function inactiveOverrideChanged() {
        if ($get("inactiveOverride"))
            show("inactiveAddresses2");
        else
            hide("inactiveAddresses2");
    }

    function removeBackgroundImage() {
        var selectors = [
            'img[src="resources/dojo/src/widget/templates/images/Tree/treenode_blank.gif"]',
            'img[src="resources/dojo/src/widget/templates/images/Tree/treenode_expand_minus.gif"]',
            'img[src="resources/dojo/src/widget/templates/images/Tree/treenode_expand_plus.gif"]'
        ];
        selectors.forEach(function(selector) {
            var elements = document.querySelectorAll(selector);
            elements.forEach(function(element) {
                element.style.backgroundImage = 'none';
            });
        });
    }
    
  </script>

  <table class="subPageHeader container" id="eventHandlerHeader"><tr><td>
    <%-- <a href="#" class="nav-link" title="<fmt:message key='eventHandlers.eventHandlers'/>">
        <i class="bi bi-gear text-blue-add align-middle me-4 fs-5"></i>
    </a> --%>
  </td></tr></table>

  <table class="subPageHeader container" cellpadding="0" cellspacing="0">
    <tr>
      <td valign="top">
        <div class="left-menu m-3 h-100">
          <div class="my-3">
        <span class="smallTitle"><fmt:message key="eventHandlers.eventHandlers"/></span>
        <tag:help id="eventHandlers"/>
          </div>
          <div class="mb-2">
        <span class="smallTitle"><fmt:message key="eventHandlers.types"/></span>
          </div>
          <div dojoType="TreeBasicController" widgetId="controller"></div>
          <i id="loadingImg" class="bi bi-hourglass-split text-blue-add align-middle mx-2 fs-5"></i>
          <div id="tree" style="display:none;" class="my-4">
        <div dojoType="Tree" widgetId="eventTypeTree" listeners="controller" toggle="wipe">
          <div dojoType="TreeNode" title="<i class='bi bi-bell text-blue-add align-middle mx-2 fs-5'></i> <fmt:message key='eventHandlers.pointEventDetector'/>" widgetId="rootPoint"></div>
          <div dojoType="TreeNode" title="<i class='bi bi-calendar-check text-blue-add align-middle mx-2 fs-5'></i> <fmt:message key='scheduledEvents.ses'/>" widgetId="rootScheduled"></div>
          <div dojoType="TreeNode" title="<i class='bi bi-calendar-week text-blue-add align-middle mx-2 fs-5'></i> <fmt:message key='compoundDetectors.compoundEventDetectors'/>" widgetId="rootCompound"></div>
          <div dojoType="TreeNode" title="<i class='bi bi-database-add text-blue-add align-middle mx-2 fs-5'></i> <fmt:message key='eventHandlers.dataSourceEvents'/>" widgetId="rootDataSource"></div>
          <div dojoType="TreeNode" title="<i class='bi bi-upload text-blue-add align-middle mx-2 fs-5'></i> <fmt:message key='eventHandlers.publisherEvents'/>" widgetId="rootPublisher"></div>
          <div dojoType="TreeNode" title="<i class='bi bi-wrench-adjustable-circle text-blue-add align-middle mx-2 fs-5'></i> <fmt:message key='eventHandlers.maintenanceEvents'/>" widgetId="rootMaintenance"></div>
          <div dojoType="TreeNode" title="<i class='bi bi-gear text-blue-add align-middle mx-2 fs-5'></i> <fmt:message key='eventHandlers.systemEvents'/>" widgetId="rootSystem"></div>
          <div dojoType="TreeNode" title="<i class='bi bi-shield text-blue-add align-middle mx-2 fs-5'></i> <fmt:message key='eventHandlers.auditEvents'/>" widgetId="rootAudit"></div>
        </div>
          </div>
        </div>
      </td>

      <td valign="top">
        <div id="handlerEditDiv" class="right-box m-3" style="display:none;">
          <table class="w-100 m-3">
            <tr>
              <td class="smallTitle"><fmt:message key="eventHandlers.eventHandler"/></td>
              <td align="right">
                  <i id="deleteImg" class="bi bi-trash  text-danger align-middle me-4 fs-5" title="<fmt:message key='common.delete'/>" onclick="deleteHandler();"></i>
                  <i id="saveImg" class="bi bi-floppy2-fill text-blue-add align-middle me-4 fs-5" title="<fmt:message key='common.save'/>" onclick="saveHandler();"></i>
              </td>
            </tr>
            <tr><td class="formError" id="userMessage"></td></tr>
          </table>

          <table class="w-100 m-3">
            <tr>
              <td class="formLabelRequired align-middle my-2"><fmt:message key="eventHandlers.type"/></td>
              <td class="d-flex align-items-center justify-content-start">
                <select class="w-50 form-select form-select-sm my-2" id="handlerTypeSelect" onchange="handlerTypeChanged()">
                  <option value="<c:out value="<%= EventHandlerVO.TYPE_EMAIL %>"/>"><fmt:message key="eventHandlers.type.email"/></option>
                  <option value="<c:out value="<%= EventHandlerVO.TYPE_SET_POINT %>"/>"><fmt:message key="eventHandlers.type.setPoint"/></option>
                  <option value="<c:out value="<%= EventHandlerVO.TYPE_PROCESS %>"/>"><fmt:message key="eventHandlers.type.process"/></option>
                  <option value="<c:out value="<%= EventHandlerVO.TYPE_SCRIPT %>"/>"><fmt:message key="eventHandlers.type.script"/></option>
                  <option value="<c:out value="<%= EventHandlerVO.TYPE_SMS %>"/>"><fmt:message key="eventHandlers.type.sms"/></option>
                </select>
                <i id="handler1Img" class="bi bi-wrench text-blue-add align-middle ms-2 fs-5" title="<fmt:message key='eventHandlers.type.setPointHandler'/>" style="display:none;"></i>
                <i id="handler2Img" class="bi bi-envelope text-blue-add align-middle ms-2 fs-5" title="<fmt:message key='eventHandlers.type.emailHandler'/>" style="display:none;"></i>
                <i id="handler3Img" class="bi bi-gear text-blue-add align-middle ms-2 fs-5" title="<fmt:message key='eventHandlers.type.processHandler'/>" style="display:none;"></i>
                <i id="handler4Img" class="bi bi-file-earmark-text text-blue-add align-middle ms-2 fs-5" title="<fmt:message key='eventHandlers.type.processHandler'/>" style="display:none;"></i>
                <i id="handler5Img" class="bi bi-phone text-blue-add align-middle ms-2 fs-5" title="<fmt:message key='eventHandlers.type.smsHandler'/>" style="display:none;"></i>
                <span id="handler5Help" style="display:none;">
                    <tag:help id="smsEventHandlers"/>
                </span>
              </td>
            </tr>

            <tr>
              <td class="formLabelRequired align-middle my-2"><fmt:message key="common.xid"/></td>
              <td class="formField"><input class="w-75 form-control form-control-sm my-2" type="text" id="xid"/></td>
            </tr>

            <tr>
              <td class="formLabelRequired align-middle my-2"><fmt:message key="eventHandlers.alias"/></td>
              <td class="formField"><input id="alias" class="w-75 form-control form-control-sm my-2" type="text"/></td>
            </tr>

            <tr>
              <td class="formLabelRequired align-middle my-2"><fmt:message key="common.disabled"/></td>
              <td class="formField"><input class="form-check-input custom-checkbox my-2" type="checkbox" id="disabled"/></td>
            </tr>

            <tr><td class="m-4" colspan="2"><hr class="border border-secondary w-75 my-4 mx-auto"/></td></tr>
          </table>

          <table id="handler<c:out value="<%= EventHandlerVO.TYPE_SET_POINT %>"/>" style="display:none" class="w-100 m-3">
            <tr>
              <td class="formLabelRequired align-middle my-2"><fmt:message key="eventHandlers.target"/></td>
              <td class="formField">
                <select class="w-50 form-select form-select-sm my-2" id="targetPointSelect" onchange="targetPointSelectChanged()"></select>
              </td>
            </tr>

            <tr>
              <td class="formLabelRequired align-middle my-2"><fmt:message key="eventHandlers.activeAction"/></td>
              <td class="formField">
                <select class="w-50 form-select form-select-sm my-2" id="activeAction" onchange="activeActionChanged()">
                  <option value="<c:out value="<%= EventHandlerVO.SET_ACTION_NONE %>"/>"><fmt:message key="eventHandlers.action.none"/></option>
                  <option value="<c:out value="<%= EventHandlerVO.SET_ACTION_POINT_VALUE %>"/>"><fmt:message key="eventHandlers.action.point"/></option>
                  <option value="<c:out value="<%= EventHandlerVO.SET_ACTION_STATIC_VALUE %>"/>"><fmt:message key="eventHandlers.action.static"/></option>
                </select>
              </td>
            </tr>

            <tr id="activePointIdRow">
              <td class="formLabel"><fmt:message key="eventHandlers.sourcePoint"/></td>
              <td class="formField"><select class="w-50 form-select form-select-sm my-2" id="activePointId"></select></td>
            </tr>

            <tr id="activeValueToSetRow">
              <td class="formLabel"><fmt:message key="eventHandlers.valueToSet"/></td>
              <td class="formField" id="activeValueToSetContent"></td>
            </tr>

            <tr>
              <td class="formLabelRequired align-middle my-2"><fmt:message key="eventHandlers.inactiveAction"/></td>
              <td class="formField">
                <select class="w-50 form-select form-select-sm my-2" id="inactiveAction" onchange="inactiveActionChanged()">
                  <option value="<c:out value="<%= EventHandlerVO.SET_ACTION_NONE %>"/>"><fmt:message key="eventHandlers.action.none"/></option>
                  <option value="<c:out value="<%= EventHandlerVO.SET_ACTION_POINT_VALUE %>"/>"><fmt:message key="eventHandlers.action.point"/></option>
                  <option value="<c:out value="<%= EventHandlerVO.SET_ACTION_STATIC_VALUE %>"/>"><fmt:message key="eventHandlers.action.static"/></option>
                </select>
              </td>
            </tr>

            <tr id="inactivePointIdRow">
              <td class="formLabel"><fmt:message key="eventHandlers.sourcePoint"/></td>
              <td class="formField"><select class="w-50 form-select form-select-sm my-2" id="inactivePointId"></select></td>
            </tr>

            <tr id="inactiveValueToSetRow">
              <td class="formLabel"><fmt:message key="eventHandlers.valueToSet"/></td>
              <td class="formField" id="inactiveValueToSetContent"></td>
            </tr>
          </table>

          <table id="handler<c:out value="<%= EventHandlerVO.TYPE_EMAIL %>"/>" style="display:none" class="w-100 m-3">
            <tbody id="emailRecipients"></tbody>

            <tr><td class="m-4" colspan="2"><hr class="border border-secondary w-75 my-4 mx-auto"/></td></tr>

            <tr>
              <td class="formLabelRequired align-middle my-2"><fmt:message key="eventHandlers.escal"/></td>
              <td class="formField"><input id="sendEscalation" class="form-check-input custom-checkbox my-2" type="checkbox" onclick="sendEscalationChanged()"/></td>
            </tr>

            <tr id="escalationAddresses1">
              <td class="formLabelRequired align-middle my-2"><fmt:message key="eventHandlers.escalPeriod"/></td>
              <td class="formField">
                <input id="escalationDelay" class="w-75 form-control form-control-sm my-2" type="text" class="formShort"/>
                <select class="w-50 form-select form-select-sm my-2" id="escalationDelayType">
                  <tag:timePeriodOptions min="true" h="true" d="true"/>
                </select>
              </td>
            </tr>

            <tbody id="escalRecipients"></tbody>

            <tr><td class="m-4" colspan="2"><hr class="border border-secondary w-75 my-4 mx-auto"/></td></tr>

            <tr>
              <td class="formLabelRequired align-middle my-2"><fmt:message key="eventHandlers.inactiveNotif"/></td>
              <td class="formField"><input id="sendInactive" class="form-check-input custom-checkbox my-2" type="checkbox" onclick="sendInactiveChanged()"/></td>
            </tr>

            <tr id="inactiveAddresses1">
              <td class="formLabelRequired align-middle my-2"><fmt:message key="eventHandlers.inactiveOverride"/></td>
              <td class="formField"><input id="inactiveOverride" class="form-check-input custom-checkbox my-2" type="checkbox" onclick="inactiveOverrideChanged()"/></td>
            </tr>

            <tbody id="inactiveRecipients"></tbody>
          </table>

          <table id="handler<c:out value="<%= EventHandlerVO.TYPE_SMS %>"/>" style="display:none" class="w-100 m-3">
            <tbody id="smsRecipients"></tbody>
          </table>
          
          <table id="handler<c:out value="<%= EventHandlerVO.TYPE_PROCESS %>"/>" style="display:none" class="w-100 m-3">
            <tr>
              <td class="formLabelRequired align-middle my-2"><fmt:message key="eventHandlers.activeCommand"/></td>
              <td class="d-flex align-items-center justify-content-start">
                <input class="w-75 form-control form-control-sm my-2" type="text" id="activeProcessCommand" class="formLong"/>
                <i class="bi bi-gear-fill text-blue-add align-middle ms-2 fs-5" onclick="testProcessCommand('activeProcessCommand')" title="<fmt:message key='eventHandlers.commandTest.title'/>"></i>
              </td>
            </tr>
            
            <tr>
              <td class="formLabelRequired align-middle my-2"><fmt:message key="eventHandlers.inactiveCommand"/></td>
              <td class="d-flex align-items-center justify-content-start">
                <input class="w-75 form-control form-control-sm my-2" type="text" id="inactiveProcessCommand" class="formLong"/>
                <i class="bi bi-gear-fill text-blue-add align-middle ms-2 fs-5" onclick="testProcessCommand('inactiveProcessCommand')" title="<fmt:message key='eventHandlers.commandTest.title'/>"></i>
              </td>
            </tr>
          </table>
          
          <table id="handler<c:out value="<%= EventHandlerVO.TYPE_SCRIPT %>"/>" style="display:none" class="w-100 m-3">
            <tr>
              <td class="w-25 formLabelRequired align-middle my-2"><fmt:message key="eventHandlers.activeScript"/></td>
              <td class="d-flex align-items-center justify-content-start">
              	<select class="w-75 form-select form-select-sm my-2" id="activeScriptCommand"></select>
                <i class="bi bi-gear-fill text-blue-add align-middle ms-2 fs-5" onclick="testScriptCommand('activeScriptCommand')" title="<fmt:message key='eventHandlers.commandTest.title'/>"></i>
              </td>
            </tr>
            
            <tr>
              <td class="w-25 formLabelRequired align-middle my-2"><fmt:message key="eventHandlers.inactiveScript"/></td>
              <td class="d-flex align-items-center justify-content-start">
                <select class="w-75 form-select form-select-sm my-2" id="inactiveScriptCommand"></select>
                <i class="bi bi-gear-fill text-blue-add align-middle ms-2 fs-5" onclick="testScriptCommand('inactiveScriptCommand')" title="<fmt:message key='eventHandlers.commandTest.title'/>"></i>
              </td>
            </tr>
          </table>
          
          <table>
            <tbody id="genericMessages"></tbody>
          </table>
        </div>
      </td>
    </tr>
  </table>
</tag:page>