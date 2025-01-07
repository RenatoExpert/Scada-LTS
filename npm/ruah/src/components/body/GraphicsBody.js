import Component from "../../prototype/Component";
import Graphics from "../../prototype/graphics/Graphics";

class GraphicsBody extends Component {
    constructor (map) {
        let nodeTag = "div";
        let className = "hp-graphicsbody";
        super(map, nodeTag, className);
        this.#make_child();
    }

    #make_child () {
        let graphics = new Graphics(this.map);
        this.node.appendChild(graphics.node);
    }
}

export default GraphicsBody;