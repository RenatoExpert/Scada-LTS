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

<tag:page onload="initPage" dwr="EmportDwr">
  <script type="text/javascript">

    window.onunload = function() {
        EmportDwr.importCancelled();
    };
    
    function initPage() {
        
    }

    function loadProject() {
		resp = confirm("<fmt:message key="emport.confirmImport"/>");

		if(!resp)
			return;
        
    	setDisabled("loadBtn", true);
    	messages = [createValidationMessage("importMessages","<fmt:message key="emport.importInit"/>")];
		showDwrMessages(messages);
		hide("eventsRow");
		hide("subHeader");

        EmportDwr.loadProject(
                function(success) {
                    if(success) {
                    	importUpdate();
                    } else {
                    	messages = [createValidationMessage("importMessages","<fmt:message key="emport.importFailed"/>")];
                		showDwrMessages(messages);
                    }
                	
        	});
    }

    function importUpdate() {
        EmportDwr.importUpdate(function(response) {
            if (response.data.noImport) {
            	setDisabled("loadBtn", false);
            	return;
            }
            
            $set("alternateMessage", "<fmt:message key="emport.importProgress"/>");
            setDisabled("loadBtn", true);
            showDwrMessages(response.messages, $("importMessages"));
            
            if (response.data.cancelled || response.data.complete) {
                setDisabled("loadBtn", false);
                
                if (response.data.cancelled)
                    $set("alternateMessage", "<fmt:message key="emport.importCancelled"/>");
                else {
                	window.onunload = function() {};
                	$set("alternateMessage", "<fmt:message key="emport.importComplete"/>");
                	alert("<fmt:message key="emport.importCompleteWarn"/>");
                	window.location = "logout.htm";
                }
                    
            }
            else
                setTimeout(importUpdate, 1000);
        });
    }

  </script>
  
    
<div class="container">
	<div class="row">
		<div class="col-md-6">
			<div class="right-box my-3">
				<table class="w-100 m-3">
					<c:if test="${!empty errorMessages}">
						<tr>
							<td> <fmt:message key="emport.errorMessage"/> </td>
						</tr>
						<tr>
							<c:forEach items="${errorMessages}" var="error">
								<td> - ${error} </td>
							</c:forEach>
						</tr>
					</c:if>
					<c:if test="${empty errorMessages}">
						<td>
							<span class="smallTitle"><fmt:message key="emport.importProjectTitle"/></span>
							<tag:help id="importProject"/>
						</td>
						<tr>
							<td><hr class="border border-secondary w-100 my-4 mx-auto"/></td>
							<td><hr class="border border-secondary w-75 my-4 me-5 mx-auto"/></td>
						</tr>
						<tr>
							<td class="formLabelRequired align-middle my-2"><fmt:message key="emport.projectName"/></td>
							<td> ${projectName} </td>
						</tr>
						<tr>
							<td class="formLabelRequired align-middle my-2"><fmt:message key="emport.projectDescription"/></td>
							<td> ${projectDescription} </td>
						</tr>
						<tr>
							<td class="formLabelRequired align-middle my-2"><fmt:message key="emport.serverVersion"/></td>
							<td> ${projectServerVersion} </td>
						</tr>
						<tr>
							<td class="formLabelRequired align-middle my-2"><fmt:message key="emport.exportDate"/></td>
							<td> ${exportDate} </td>
						</tr>
						<tr>
							<td><hr class="border border-secondary w-100 my-4 mx-auto"/></td>
							<td><hr class="border border-secondary w-75 my-4 me-5 mx-auto"/></td>
						</tr>
						<tbody id="importMessages"></tbody>
						<tr><td id="alternateMessage"></td></tr>
						<tr>
							<td>
							</td>
							<td>
								<button id="loadBtn" type="button" class="btn btn-primary custom-btn-blue ms-3" onclick="loadProject();"><fmt:message key="emport.importButton"/></button>
								<%-- <input id="loadBtn" type="button" value="<fmt:message key="emport.importButton"/>" onclick="loadProject();"/> --%>
							</td>
						</tr>
					</c:if>
				</table>
			</div>
		</div>
	</div>
</div>
  
  
</tag:page>