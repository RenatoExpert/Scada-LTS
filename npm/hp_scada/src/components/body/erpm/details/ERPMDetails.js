import ASSETSAPI from "../../../../lib/ASSETSAPI";
import Component from "../../../../prototype/Component";

class ERPMDetails extends Component {
    constructor (map) {
        let nodeTag = "div";
        let className = "hp-erpmdetails";
        super(map, nodeTag, className);
        this.#make_child();
    }

    #make_child () {
        let stationType = this.map.levelmap[3].class;
        let path;
        switch (stationType) {
            case "rpm-single":
                path = "hp/bg/rpm-single.svg";
                break;
            case "rpm-double":
                path = "hp/bg/rpm-double.svg";
                break;
            default:
                console.warn(`stationType must be 'rpm-single' or 'rpm-double': ${stationType}`);
                path = "hp/bg/rpm-single.svg";
        }
        ASSETSAPI.fetch_svg(path).then(svg => {
            this.node.appendChild(svg);
        });
    }
}

export default ERPMDetails;