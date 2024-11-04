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
--%><%@include file="/WEB-INF/tags/decl.tagf"%><%--
--%><%@tag body-content="empty"%>
<table class="mx-4">
  <tr>
    <td class="p-2 text-center"><fmt:message key="common.dateRangeFrom"/></td>
    <td><input class="form-control form-control-sm my-2" type="text" id="fromYear" class="formVeryShort" value="${fromYear}"/></td>
    <td><select class="form-select form-select-sm my-2" id="fromMonth" value="${fromMonth}"><tag:monthOptions sst="true"/></select></td>
    <td><select class="form-select form-select-sm my-2" id="fromDay" value="${fromDay}"><tag:dayOptions sst="true"/></select></td>
    <td>,</td>
    <td><select class="form-select form-select-sm my-2" id="fromHour" value="${fromHour}"><tag:hourOptions sst="true"/></select></td>
    <td>:</td>
    <td><select class="form-select form-select-sm my-2" id="fromMinute" value="${fromMinute}"><tag:minuteOptions sst="true"/></select></td>
    <td>:</td>
    <td><select class="form-select form-select-sm my-2" id="fromSecond" value="${fromSecond}"><tag:secondOptions sst="true"/></select></td>
    <td></td><td class="p-2 text-center"><input class="form-check-input custom-checkbox my-2" type="checkbox" name="fromNone" id="fromNone" onclick="updateDateRange()"/>
    <td class="p-2 text-center"><label for="fromNone"><fmt:message key="common.inception"/></label></td></td>
  </tr>
  <tr>
    <td class="p-2 text-center"><fmt:message key="common.dateRangeTo"/></td>
    <td><input class="form-control form-control-sm my-1" type="text" id="toYear" class="formVeryShort" value="${toYear}"/></td>
    <td><select class="form-select form-select-sm my-2" id="toMonth" value="${toMonth}"><tag:monthOptions sst="true"/></select></td>
    <td><select class="form-select form-select-sm my-2" id="toDay" value="${toDay}"><tag:dayOptions sst="true"/></select></td>
    <td>,</td>
    <td><select class="form-select form-select-sm my-2" id="toHour" value="${toHour}"><tag:hourOptions sst="true"/></select></td>
    <td>:</td>
    <td><select class="form-select form-select-sm my-2" id="toMinute" value="${toMinute}"><tag:minuteOptions sst="true"/></select></td>
    <td>:</td>
    <td><select class="form-select form-select-sm my-2" id="toSecond" value="${toSecond}"><tag:secondOptions sst="true"/></select></td>
    <td></td><td class="p-2 text-center"><input class="form-check-input custom-checkbox my-2" type="checkbox" name="toNone" id="toNone" checked="checked" onclick="updateDateRange()"/>
    <td class="p-2 text-center"><label for="toNone"><fmt:message key="common.latest"/></label></td></td>
  </tr>
</table>
