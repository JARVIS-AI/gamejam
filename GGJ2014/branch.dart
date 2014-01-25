part of game;

class Branch extends Sprite {
    num water;
    num energy;
    num thickness;

    num baseRotation = 0.0;

    num valve = 0.5;
    bool isDragging = false;
    Vector dragStartPoint = null;

    GlassPlate shape;
    TextField branchText = new TextField();

    Branch(this.thickness) {
        water = this.thickness;
        energy = this.thickness;

        shape = new GlassPlate(thickness, 1);
        shape.pivotX = thickness/2;
        shape.pivotY = 1;
        addChild(shape);

        y = -1;
        onEnterFrame.listen(_onEnterFrame);

        branchText.defaultTextFormat = new TextFormat('monospace', 10, Color.White);
        branchText.scaleX = 0.01;
        branchText.scaleY = 0.01;
        branchText.y = -0.5;
        branchText.text = "branchText";
        branchText.mouseEnabled = false;
        this.mouseEnabled = false;
        addChild(branchText);
    }

    int get depth => parent is Branch ? parent.depth + 1 : 0;

    bool get isRoot => !(parent is Branch);

    bool get isEndBranch => branches.length == 0;

    List<Branch> get branches {
        List<Branch> result = new List<Branch>();
        for(int i = 0; i < numChildren; i++) {
            if(getChildAt(i) is Branch) result.add(getChildAt(i));
        }
        return result;
    }

    List<Leaf> get leaves {
        List<Leaf> result = new List<Leaf>();
        for(int i = 0; i < numChildren; i++) {
            if(getChildAt(i) is Leaf) result.add(getChildAt(i));
        }
        return result;
    }

    void growLeaves([int num = 30]) {
        for(int i = 0; i < num; ++i) {
            addChild(new LeafBranch(this));
        }
    }

    void _onEnterFrame(EnterFrameEvent e) {
        // Update debug info
        branchText.text = "D${depth}";
        branchText.text += "\nW${water.toStringAsFixed(2)}";
        branchText.text += "\nE${energy.toStringAsFixed(2)}";
        branchText.text += "\nV${valve.toStringAsFixed(2)}";
        branchText.visible = debug;

        this.rotation = lerp(baseRotation, PI * .5, Wind.power * 0.003);

        num st = getStartThickness();
        num et = thickness;

        this.graphics.clear();

        if(isRoot) {
            Spline spline = new Spline();
            addPoints(spline, this);
            spline.generatePath(graphics);
            graphics.fillColor(0xFF000000);
            graphics.strokeColor(0, 0);
        } else if(isEndBranch) {
            Spline spline = new Spline();
            addVeinPoints(spline, this, null, 0);
            spline.generatePath(graphics);
            graphics.strokeColor(Color.White, 0.01);
        }
    }

    void addPoints(Spline spline, Branch root) {
        num st = getStartThickness();
        num et = thickness;

        num tangentLength = isEndBranch ? 0.0 : 0.3;

        // going up on the left
        if(isRoot) {
            spline.add(root.globalToLocal(localToGlobal(new Point(-st/2 * 1.5, 0.2))), 0.1);
            spline.add(root.globalToLocal(localToGlobal(new Point(-st/2,  0))), 0.1);
        }
        spline.add(root.globalToLocal(localToGlobal(new Point(-et/2, -1))), tangentLength);

        // sort children
        sortChildren((var l, var r) {
            if(l is Branch && r is Branch) {
                return l.baseRotation.compareTo(r.baseRotation);
            } else {
                return 0;
            }
        });

        int numBranches = branches.length;
        int branchNumber = 0;
        for(Branch branch in branches) {
            if(branchNumber > 0) {
                spline.add(root.globalToLocal(localToGlobal(new Point(et*(branchNumber*1.0/numBranches - 0.5), -1.2))), 0.0);
            }
            branch.addPoints(spline, root);
            branchNumber++;
        }

        // going down on the right
        spline.add(root.globalToLocal(localToGlobal(new Point(et/2, -1))), tangentLength);
        if(isRoot) {
            spline.add(root.globalToLocal(localToGlobal(new Point(st/2, 0))), 0.1);
            spline.add(root.globalToLocal(localToGlobal(new Point(st/2 * 1.5, 0.2))), 0.1);
        }
    }

    void addVeinPoints(Spline spline, Branch end_branch, Branch from, num offset) {
        num tangentLength = 0.3;

        if(from != null) {
            int index = this.branches.indexOf(from) + 1;
            offset += ((index/(this.branches.length+1))-0.5)*thickness;
            debugMessage = offset;
        }
        spline.add(end_branch.globalToLocal(localToGlobal(new Point(offset, -1))), tangentLength);
        if(!isRoot) {
            this.parent.addVeinPoints(spline, end_branch, this, offset);
        } else {
        spline.add(end_branch.globalToLocal(localToGlobal(new Point(offset * 0.5, 0))), tangentLength);
        }
    }

    num getStartThickness() {
        return isRoot ? thickness : parent.thickness;
    }

    num getAbsoluteAngle() {
        return isRoot ? rotation : parent.rotation + rotation;
    }

    void dragStart(MouseEvent event) {
        isDragging = true;
        dragStartPoint = new Vector(mouseX, mouseY);

        print("Drag start");
    }

    void dragInProgress(MouseEvent event) {
        event.stopPropagation();

        if(isDragging) {
            if(mode == "valve") {
                valve = (valve - (mouseY - dragStartPoint.y)).clamp(0, 1);
                dragStartPoint = new Vector(mouseX, mouseY);
            }
        }
    }

    void dragStop(MouseEvent event) {
        if(!isDragging) return;
        isDragging = false;

        if(mode == "branch") {
            var mouse = new Vector(mouseX, mouseY);
            growChild(mouse.rads);
        }

        print("Drag stop");
    }

    void growChild(num absolute_angle) {
        Branch b = new Branch(thickness * 0.5);
        b.rotation = absolute_angle - getAbsoluteAngle();
        addChild(b);
    }

    Vector getTipPosition() {
        var p = view.globalToLocal(localToGlobal(new Point(0, 0)));
        return new Vector(p.x, p.y);
    }
}
