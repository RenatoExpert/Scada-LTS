import Component from "../Component";

class Graphics extends Component {
    constructor (map) {
        let nodeTag = "div";
        let className = "hp-graphics";
        super(map, nodeTag, className);
        this.#make_child();
    }

    #make_child () {
        let span = document.createElement('span');
        span.textContent = "Graphics";
        this.node.appendChild(span);
    }
}

export default Graphics;