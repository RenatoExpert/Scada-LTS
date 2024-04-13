package br.org.scadabr.rt.dataSource.opcua;

import br.org.scadabr.vo.dataSource.opcua.OPCUAPointLocatorVO;

import com.serotonin.mango.rt.dataSource.PointLocatorRT;

public class OPCUAPointLocatorRT extends PointLocatorRT {
	private final OPCUAPointLocatorVO vo;

	public OPCUAPointLocatorRT(OPCUAPointLocatorVO vo) {
		this.vo = vo;
	}

	@Override
	public boolean isSettable() {
		// TODO Auto-generated method stub
		return vo.isSettable();
	}

	public OPCUAPointLocatorVO getVo() {
		return vo;
	}

}
