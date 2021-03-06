TextActor = gamvas.Actor.extend( {
    create: function(name, text, x, y, size, color) {
		this._super(name, x, y);
		this.text = text;
        this.scale = typeof scale !== 'undefined' ? scale : 1;
        this.color = typeof color !== 'undefined' ? color : '#fff';
        this.size = typeof size !== 'undefined' ? size : 30;
		this.font = '' + this.size + 'px Steamwreck';
	},
	
	draw: function(t) {
		var st = gamvas.state.getCurrentState();
        st.c.fillStyle = this.color;
        st.c.font = this.font;
        st.c.textAlign = "left";
		st.c.fillText(this.text, this.position.x, this.position.y);
	}
});

LevelName = TextActor.extend({
    create: function(text) {
		this._super("levelname", text, 0, 0, 20);
        this.layer = -10000;
        this.font = '16px Skranji';
	},
    
    draw: function(t) {
        var s = gamvas.state.getCurrentState();
        var w = s.dimension.w;
        var h = 23;

        var offset = new gamvas.Vector2D(
            s.camera.position.x - s.dimension.w / 2,
            s.camera.position.y + s.dimension.h / 2 - h
            );

        var st = gamvas.state.getCurrentState();
        
        s.c.fillStyle = 'rgba(0, 0, 0, 0.8)';
        s.c.fillRect(offset.x, offset.y, w, h);
        
        s.c.fillStyle = this.color;
        s.c.font = this.font;
        s.c.textAlign = "center";
		s.c.fillText(this.text, offset.x + w / 2, offset.y + h - 4);
    }
});
