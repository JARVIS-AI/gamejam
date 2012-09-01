
Tile = gamvas.Actor.extend({
    create: function(name, x, y, xOffset, yOffset, tileset, layer)
    {
        this._super(name, (x + 0.5) * TILESIZE, (y + 0.5) * TILESIZE);

        var st = gamvas.state.getCurrentState();

        this.image = new gamvas.Image(st.resource.getImage(tileset));
        //this.image.position = new gamvas.Vector2D(this.position.x, this.position.y);
        this.image.position = this.position;
        this.image.move(-(xOffset + 0.5) * TILESIZE, -(yOffset + 0.5) * TILESIZE);
        this.image.setClipRect(xOffset * TILESIZE, yOffset * TILESIZE, TILESIZE, TILESIZE);
        
        this.layer = layer;
    },
    
    draw: function(t)
    {
        // and you thought YOU were hacking
        this.image.draw();
    }
});

CollisionTile = gamvas.Actor.extend({
    blockWind: true,
    create: function(name, x, y, collisionindex)
    {
        this._super(name, (x + 0.5) * TILESIZE, (y + 0.5) * TILESIZE);
        this.type = "tile";

        // create a static (non moving) rectangle
        this.bodyRect(this.position.x, this.position.y, TILESIZE, TILESIZE, gamvas.physics.STATIC);
        this.fixture.SetRestitution(0);
    }
});

DeathTile = gamvas.Actor.extend({
    create: function(name, x, y, collisionindex)
    {
        this._super(name, (x + 0.5) * TILESIZE, (y + 0.75) * TILESIZE);

        // create a static (non moving) rectangle
        this.bodyRect(this.position.x, this.position.y, TILESIZE, TILESIZE / 2, gamvas.physics.STATIC);
        this.setSensor(true);
    }
});