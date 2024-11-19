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
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<%@include file="/WEB-INF/tags/decl.tagf"%>
<%@tag import="com.serotonin.mango.Common"%>
<%@attribute name="pointHelpId" required="true"%>

<table class="container" cellpadding="0" cellspacing="0" id="pointProperties" style="display:none;">
  <tr>
    <td valign="top">
      <div class="right-box my-3">
        <table class="w-100  m-3">
          <tr>
            <td class="smallTitle m-3"><fmt:message key="dsEdit.points.points"/></td>
            <td align="right">
                <i id="enableAllImg" class="bi bi-puzzle-fill text-success align-middle me-3 fs-5" onclick="enableAllPoints()" title="<fmt:message key='common.enableAll'/>" style="cursor: pointer;"></i>
                <i id="editImg${applicationScope['constants.Common.NEW_ID']}" class="bi bi-database-fill-add text-blue-add align-middle me-4 fs-5" onclick="editPoint(${applicationScope['constants.Common.NEW_ID']})" title="<fmt:message key='common.addPoint'/>" style="cursor: pointer;"></i>
            </td>
          </tr>
        </table>
        <table cellspacing="1" class="align-middle text-center table table-light table-hover">
          <tr class="rowHeader" id="pointListHeaders"></tr>
          <tbody id="pointsList"></tbody>
        </table>
      </div>
    </td>

    <td valign="top">
      <div id="pointDetails" class="right-box m-3 w-75" style="display: none;position: relative;">
        <table class="w-100  m-3">
          <tr>
            <td>
              <span class="smallTitle"><fmt:message key="dsEdit.points.details"/></span>
              <tag:help id="${pointHelpId}"/>
            </td>
            <td align="right">
              <i id="pointSaveImg" class="bi bi-floppy2-fill text-blue-add align-middle me-3 fs-5" onclick="savePoint()" title="<fmt:message key='common.save'/>" style="cursor: pointer;"></i>
              <i id="pointDeleteImg" class="bi bi-trash  text-danger  align-middle me-4 fs-5" onclick="deletePoint()" title="<fmt:message key='common.delete'/>" style="cursor: pointer;"></i>
            </td>
          </tr>
        </table>
        <div id="pointMessage" class="ctxmsg formError"></div>

        <table>
          <tr>
            <td class="formLabelRequired align-middle my-2"><fmt:message key="dsEdit.points.name"/></td>
            <td class="formField" style="width:100%;"><input class="form-control form-control-sm my-2" style="width:90%;" type="text" id="name"/></td>
          </tr>
          <tr>
            <td class="formLabelRequired align-middle my-2"><fmt:message key="common.xid"/></td>
            <td class="formField" style="width:100%;"><input class="form-control form-control-sm my-2" style="width:90%;" type="text" id="xid"/></td>
          </tr>
          
          <jsp:doBody/>
          
        </table>
      </div>
    </td>
  </tr>
</table>