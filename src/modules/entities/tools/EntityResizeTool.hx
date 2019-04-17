package modules.entities.tools;

class EntityResizeTool extends EntityTool
{

	public var resizing:Bool = false;
	public var entities:Array<Entity>;
	public var lastPos:Vector = new Vector();
	public var start:Vector = new Vector();
	public var mousePos:Vector = new Vector();
	public var firstChange:Bool = false;
	public var canResizeX:Bool = false;
	public var canResizeY:Bool = false;

	public function drawOverlay()
	{
		if (!resizing) return;
		EDITOR.overlay.drawLine(start, mousePos, Color.white);
		EDITOR.overlay.drawLineNode(start, 10 / EDITOR.level.zoom, Color.green);
		if (canResizeX) EDITOR.overlay.drawLine(start, new Vector(lastPos.x, start.y), Color.green);
		if (canResizeY) EDITOR.overlay.drawLine(start, new Vector(start.x, lastPos.y), Color.green);
	}

	public function onMouseDown(pos:Vector)
	{
		entities = layer.entities.getGroup(layerEditor.selection);

		if (entities.length == 0) return;
		pos.clone(mousePos);
		layer.snapToGrid(pos, pos);
		pos.clone(lastPos);
		pos.clone(start);

		canResizeX = false;
		canResizeY = false;
		for (e in entities)
		{
			e.anchorSize();
			if (e.template.resizeableX) canResizeX = true;
			if (e.template.resizeableY) canResizeY = true;
		}

		if (canResizeX || canResizeY)
		{
			resizing = true;
			firstChange = false;
			EDITOR.locked = true;
			EDITOR.overlayDirty();
		}
	}

	public function onMouseUp(pos:Vector)
	{
		resizing = false;
		EDITOR.locked = false;
		EDITOR.overlayDirty();
	}

	public function onMouseMove(pos:Vector)
	{
		if (!resizing) return;
		if (!pos.equals(mousePos))
		{
			pos.clone(mousePos);
			EDITOR.overlayDirty();
		}

		if (!ogmo.ctrl) layer.snapToGrid(pos, pos);

		if (!pos.equals(lastPos))
		{
			if (!firstChange)
			{
				firstChange = true;
				EDITOR.level.store("resize entities");
			}

			for (e in entities) e.resize(new Vector(pos.x - start.x, pos.y - start.y));

			EDITOR.dirty();
			pos.clone(lastPos);
		}
	}

	public function getIcon():String return "entity-scale";
	public function getName():String return "Resize";
}