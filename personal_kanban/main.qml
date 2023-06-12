import QtQuick 2.2
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.4 as QQC1
import QtQuick.Controls.Styles 1.4 as QQC1Styles
import QtQuick 2.15 as QQ215

ApplicationWindow {
    visible: true
    width: 1200
    height: 800
    title: root.boardIndex == 1 ? "STRATEGIC" : "OPERATIONAL"
    id: root

    property int boardIndex: 0
    property bool filterColor: false
    property int filterSelectedColor: 0

    visibility: "Maximized"
    flags: Qt.Window

    signal itemDataChange(var runArgs, var itemIndex, var title, var description, var deadline, var col, var isReady);
    signal internalItemDataChange(var itemIndex, var createdDate, var doneDate);
    signal itemDelete(var itemIndex);
    signal archive();

    ListModel {
        id: colorModel
        ListElement { name: "white"; col: "white"; key: 0; }
        ListElement { name: "black"; col: "black"; key: 1; }
        ListElement { name: "red"; col: "#ff5252"; key: 2; }
        ListElement { name: "blue"; col: "#5252ff"; key: 3; }
        ListElement { name: "green"; col: "#60ff52"; key: 4; }
        ListElement { name: "yellow"; col: "#fcff52"; key: 5; }
    }

    function find(model, criteria) {
        for(var i = 0; i < model.count; ++i) if (criteria(model.get(i))) return model.get(i)
        return null
    }

    onItemDataChange: {
        if(runArgs == 0) {
            //kanbanBoardModelTodo.addData(title, description, deadline, col, isReady)
            kanbanBoardModelTodo.addData(title, description, deadline, col)
        }
        else if(runArgs == 1) {
            kanbanBoardModelTodo.changeData(itemIndex, title, description, deadline, col, isReady);
            kanbanBoardModelReady.changeData(itemIndex, title, description, deadline, col, isReady);
            kanbanBoardModelDoing.changeData(itemIndex, title, description, deadline, col, isReady);
            kanbanBoardModelDone.changeData(itemIndex, title, description, deadline, col, isReady);
        }
    }

    onInternalItemDataChange: {
        newTaskDialog.createdDate = createdDate;
        newTaskDialog.doneDate = doneDate;

        kanbanBoardModelTodo.changeInternalData(itemIndex, createdDate, doneDate);
        kanbanBoardModelReady.changeInternalData(itemIndex, createdDate, doneDate);
        kanbanBoardModelDoing.changeInternalData(itemIndex, createdDate, doneDate);
        kanbanBoardModelDone.changeInternalData(itemIndex, createdDate, doneDate);
    }

    onItemDelete: {
        if (kanbanBoardModelTodo.deleteItem(itemIndex) == 1)
            return
        if (kanbanBoardModelReady.deleteItem(itemIndex) == 1)
            return
        if (kanbanBoardModelDoing.deleteItem(itemIndex) == 1)
            return
        kanbanBoardModelDone.deleteItem(itemIndex);
    }

    onVisibleChanged: {
        root.boardIndex = kanbanBoardModelTodo.getBoardIndex();
    }

    onBoardIndexChanged: {
        kanbanBoardModelTodo.setBoardIndex(root.boardIndex, true)
        kanbanBoardModelReady.setBoardIndex(root.boardIndex, false)
        kanbanBoardModelDoing.setBoardIndex(root.boardIndex, false)
        kanbanBoardModelDone.setBoardIndex(root.boardIndex, false)
    }

    onArchive: {
        kanbanBoardModelDone.archive();
    }

    Rectangle {
        anchors.fill: parent

        Rectangle {
            id: background
            anchors.fill: parent
            color: Qt.rgba(0.1, 0.1, 0.1, 1)
            Image { source: "images/background.jpg"; anchors.fill: parent; }
        }
        
        Rectangle {
            id: toolbar
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            color: "#222222"
            opacity: 0.7
            width: 150

            Button {
                id: buttonAddTask
                anchors.top: toolbar.top
                anchors.left: toolbar.left
                anchors.right: toolbar.right
                anchors.topMargin: 15
                anchors.leftMargin: 15
                anchors.rightMargin: 15
                height: 40
                background: Rectangle { color: "transparent"; border.width: 2; border.color: "darkgrey"; radius: 3; }
                Text {
                    anchors.fill: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 12
                    color: "#FFFFFF"
                    text: "NEW TASK"
                    font.bold: true
                }

                onClicked: {
                    newTaskDialog.titleText = ""
                    newTaskDialog.descriptionText = ""
                    newTaskDialog.dueDateText = ""
                    newTaskDialog.selectedColor = 0
                    newTaskDialog.isReady = false
                    newTaskDialog.selectedColor = root.filterSelectedColor
                    newTaskDialog.runDialog(0, 0)
                }
            }

            Button {
                id: strategicButton
                anchors.top: buttonAddTask.bottom
                anchors.left: toolbar.left
                anchors.right: toolbar.right
                anchors.topMargin: 15
                anchors.leftMargin: 15
                anchors.rightMargin: 15
                height: 40
                background: Rectangle { color: root.boardIndex == 1 ? "grey" : "transparent"; border.width: 2; border.color: "darkgrey"; radius: 3; }

                highlighted: true

                Text {
                    anchors.fill: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 12
                    color: "#FFFFFF"
                    text: "STRATEGY"
                    font.bold: true
                }

                onClicked: {
                    root.boardIndex = 1;
                    root.title = "STRATEGY"
                }
            }

            Button {
                id: coordinationButton
                anchors.top: strategicButton.bottom
                anchors.left: toolbar.left
                anchors.right: toolbar.right
                anchors.topMargin: 5
                anchors.leftMargin: 15
                anchors.rightMargin: 15
                height: 40
                background: Rectangle { color: root.boardIndex == 2 ? "grey" : "transparent"; border.width: 2; border.color: "darkgrey"; radius: 3; }
                Text {
                    anchors.fill: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 12
                    color: "#FFFFFF"
                    text: "COORDINATION"
                    font.bold: true
                }

                onClicked: {
                    root.boardIndex = 2
                    root.title = "COORDINATION"
                }
            }

            Button {
                id: operationalButton
                anchors.top: coordinationButton.bottom
                anchors.left: toolbar.left
                anchors.right: toolbar.right
                anchors.topMargin: 5
                anchors.leftMargin: 15
                anchors.rightMargin: 15
                height: 40
                background: Rectangle { color: root.boardIndex == 3 ? "grey" : "transparent"; border.width: 2; border.color: "darkgrey"; radius: 3; }
                Text {
                    anchors.fill: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 12
                    color: "#FFFFFF"
                    text: "OPERATION"
                    font.bold: true
                }

                onClicked: {
                    root.title = "OPERATION"
                    root.boardIndex = 3
                }
            }

            Button {
                id: aaiButton
                anchors.top: operationalButton.bottom
                anchors.left: toolbar.left
                anchors.right: toolbar.right
                anchors.topMargin: 5
                anchors.leftMargin: 15
                anchors.rightMargin: 15
                height: 40
                background: Rectangle { color: root.boardIndex == 4 ? "grey" : "transparent"; border.width: 2; border.color: "darkgrey"; radius: 3; }
                Text {
                    anchors.fill: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 12
                    color: "#FFFFFF"
                    text: "ANNUAL"
                    font.bold: true
                }

                onClicked: {
                    root.title = "ANNUAL"
                    root.boardIndex = 4
                }
            }

            Button {
                id: colorFilterButton
                anchors.left: toolbar.left
                anchors.right: toolbar.right
                anchors.top: aaiButton.bottom
                anchors.leftMargin: 15
                anchors.rightMargin: 15
                anchors.topMargin: 15
                height: 40
                background: Rectangle { 
                    color: root.filterColor ? find(colorModel, function(item) { return item.key === root.filterSelectedColor }).col : "transparent";
                    border.width: 2;
                    border.color: "darkgrey";
                    radius: 3; 
                }
                Text {
                    anchors.fill: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 12
                    color: "#FFFFFF"
                    text: root.filterColor? "" : "FILTER" 
                    font.bold: true
                }

                onClicked: {
                    if (root.filterColor) {
                        root.filterColor = false;
                        globalColorSelectionRect.showColors = false;
                        kanbanBoardModelTodo.unFilter()
                        kanbanBoardModelReady.unFilter()
                        kanbanBoardModelDoing.unFilter()
                        kanbanBoardModelDone.unFilter()
                    }
                    else {
                        globalColorSelectionRect.showColors = !globalColorSelectionRect.showColors;
                    }
                }
                //
                // Color Selection
                Rectangle {
                    id: globalColorSelectionRect
                    height: 300;
                    anchors.left: colorFilterButton.left
                    anchors.right: colorFilterButton.right
                    radius: 3
                    color: "transparent"
                    anchors.top: colorFilterButton.bottom
                    anchors.topMargin: 5
                    property bool showColors: false 

                    ListView {
                        model: colorModel
                        anchors.fill: globalColorSelectionRect
                        visible: globalColorSelectionRect.showColors
                        spacing: 5

                        delegate: Item {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 40

                            Rectangle {
                                anchors.fill: parent
                                radius: 3
                                color: col
                                border.width: 2
                                border.color: "darkgrey"
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    globalColorSelectionRect.showColors = false
                                    root.filterColor = true
                                    root.filterSelectedColor = key
                                    kanbanBoardModelTodo.filter(key)
                                    kanbanBoardModelReady.filter(key)
                                    kanbanBoardModelDoing.filter(key)
                                    kanbanBoardModelDone.filter(key)
                                }
                                onPressAndHold: {
                                    globalColorSelectionRect.showColors = false
                                    root.filterColor = true
                                    root.filterSelectedColor = key
                                    kanbanBoardModelTodo.outFilter(key)
                                    kanbanBoardModelReady.outFilter(key)
                                    kanbanBoardModelDoing.outFilter(key)
                                    kanbanBoardModelDone.outFilter(key)
                                }
                            }
                        }
                    } // end listColors
                } // end color selection
            }

            Button {
                id: startBurndownButton
                anchors.left: toolbar.left
                anchors.right: toolbar.right
                anchors.bottom: archiveButton.top 
                anchors.leftMargin: 15
                anchors.rightMargin: 15
                anchors.bottomMargin: 15
                height: 40
                background: Rectangle { color: "transparent"; border.width: 2; border.color: "darkgrey"; radius: 3; }
                Text {
                    anchors.fill: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 12
                    color: "darkgrey"
                    text: "CHART"
                    font.bold: true
                }

                onClicked: {
                    burndown.runChart();
                }
            }

            Button {
                id: archiveButton
                anchors.left: toolbar.left
                anchors.right: toolbar.right
                anchors.bottom: closeAppButton.top 
                anchors.leftMargin: 15
                anchors.rightMargin: 15
                anchors.bottomMargin: 5
                height: 40
                background: Rectangle { color: "transparent"; border.width: 2; border.color: "darkgrey"; radius: 3; }
                Text {
                    anchors.fill: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 12
                    color: "darkgrey"
                    text: "ARCHIVE"
                    font.bold: true
                }

                onClicked: {
                    archiveDonesPopup.open();
                }
            }

            Button {
                id: closeAppButton
                anchors.left: toolbar.left
                anchors.right: toolbar.right
                anchors.bottom: toolbar.bottom
                anchors.leftMargin: 15
                anchors.rightMargin: 15
                anchors.bottomMargin: 15
                height: 40
                background: Rectangle { color: "transparent"; border.width: 2; border.color: "darkgrey"; radius: 3; }
                Text {
                    anchors.fill: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 12
                    color: "firebrick"
                    text: "CLOSE"
                    font.bold: true
                }

                onClicked: {
                    Qt.quit()
                }
            }

        }
        
        // todo-column
        // it is not possible, to create a separate file for that, so every colum is defined in main.qml
        Rectangle {
            id: todoColumn
            anchors.top: parent.top
            anchors.left: toolbar.right
            anchors.topMargin: 15
            anchors.leftMargin: 15
            anchors.bottomMargin: 15
            opacity: 0.9
            gradient: QQ215.Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "#1e1f21" }
                GradientStop { position: 1.0; color: "#222326" }
            }

            width: (parent.width - toolbar.width) / 4 - 15
            height: listTodos.height + todoText.height + 40
            radius: 5

            Text {
                id: todoText
                text: "To Do"
                anchors.top: todoColumn.top
                anchors.left: todoColumn.left
                anchors.topMargin: 10
                anchors.leftMargin: 10
                height: 18
                font.pointSize: 12
                color: Qt.rgba(0.5, 0.5, 0.5, 1)

            }

            DropArea {
                anchors.fill: parent
                onDropped: {
                    var originalIndexSource = drag.source.parent.mod.getOriginalIndex(drag.source.dragItemIndex)
                    var localIndexSource = drag.source.dragItemIndex
                    drag.source.parent.mod.setStatus(drag.source.dragItemIndex, kanbanBoardModelTodo.getStatus())
                    kanbanBoardModelTodo.resetModel()
                    drag.source.parent.mod.resetModel()
                }
            }

            ListView {
                id: listTodos
                anchors.top: todoText.bottom
                anchors.left: todoColumn.left
                anchors.right: todoColumn.right
                anchors.topMargin: 10
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 10
                height: Math.min(listTodos.count * (80 + 10), root.height - 90)
                clip: true

                model: kanbanBoardModelTodo

                property Item dragParent: dragContainerTodo

                delegate: Item {
                    id: delegateItem
                    width: listTodos.width
                    height: 80

                    Rectangle {
                        id: dragRectTodo
                        gradient: QQ215.Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: "#343437" }
                            GradientStop { position: 1.0; color: "#222222" }
                        }
                        height: 80
                        width: listTodos.width
                        radius: 5
                        opacity: 0.9

                        property int dragItemIndex: index

                        Rectangle {
                            id: colorBarRect
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            width: parent.width / 20
                            color: "transparent"
                            Rectangle {
                                id: colorBar
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                anchors.right: parent.right
                                color: find(colorModel, function(item) { return item.key === mycolor }).col
                                width: parent.width / 4
                            }

                        }

                        Rectangle {
                            id: contentRect
                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.left: colorBarRect.right
                            anchors.bottom: parent.bottom
                            color: "transparent"

                            Text {
                                text: title
                                color: "white"
                                font.pixelSize: 16
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 10
                                width: parent.width * 0.8
                                elide: Text.ElideRight
                                wrapMode: Text.WordWrap
                            }
                            Text {
                                text: deadline
                                color: "#ff5252"
                                font.pixelSize: 16
                                enabled: deadline.length > 0
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                anchors.rightMargin: 10
                                anchors.bottomMargin: 5
                            }
                        }

                        MouseArea {
                            id: mouseAreaTodo
                            anchors.fill: parent
                            drag.target: dragRectTodo

                            onClicked: {
                                newTaskDialog.titleText = title
                                newTaskDialog.descriptionText = description
                                newTaskDialog.dueDateText = deadline
                                newTaskDialog.selectedColor = mycolor
                                newTaskDialog.isReady = isReady
                                newTaskDialog.createdDate = createdDate
                                newTaskDialog.doneDate = doneDate
                                newTaskDialog.runDialog(1, kanbanBoardModelTodo.getOriginalIndex(index))
                            }

                            drag.onActiveChanged: {
                                if (mouseAreaTodo.drag.active) {
                                    dragRectTodo.dragItemIndex = index;
                                }
                                dragRectTodo.Drag.drop();
                            }
                        }

                        states: [
                            State {
                                when: dragRectTodo.Drag.active
                                ParentChange {
                                    target: dragRectTodo
                                    parent: listTodos.dragParent
                                }

                                AnchorChanges {
                                    target: dragRectTodo
                                    anchors.horizontalCenter: undefined
                                    anchors.verticalCenter: undefined
                                }
                            }
                        ]

                        Drag.active: mouseAreaTodo.drag.active
                        Drag.hotSpot.x: dragRectTodo.width / 2
                        Drag.hotSpot.y: dragRectTodo.height / 2
                    }
                    DropArea {
                        anchors.fill: parent
                        onDropped: {
                            var originalIndexSource = drag.source.parent.mod.getOriginalIndex(drag.source.dragItemIndex)
                            var originalIndexTarget = kanbanBoardModelTodo.getOriginalIndex(dragRectTodo.dragItemIndex)
                            var localIndexSource = drag.source.dragItemIndex
                            var localIndexTarget = dragRectTodo.dragItemIndex
                            drag.source.parent.mod.setStatus(drag.source.dragItemIndex, kanbanBoardModelTodo.getStatus())
                            kanbanBoardModelTodo.addByDrop(originalIndexSource, originalIndexTarget, localIndexSource, localIndexTarget)
                            drag.source.parent.mod.resetModel()
                        }
                    }
                }
            }
        }
        //
        // ---------------------------------------------------------------------------------------------

        // ready-column
        // it is not possible, to create a separate file for that, so every colum is defined in main.qml
        // --------------------------------------------------------------------------------------------
        Rectangle {
            id: readyColumn
            anchors.top: parent.top
            anchors.left: todoColumn.right
            anchors.topMargin: 15
            anchors.leftMargin: 15
            anchors.bottomMargin: 15
            opacity: 0.9
            gradient: QQ215.Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "#1e1f21" }
                GradientStop { position: 1.0; color: "#222326" }
            }
            width: (parent.width - toolbar.width) / 4 - 15
            height: listReadys.height + readyText.height + 40
            radius: 5

            Text {
                id: readyText
                text: "Specify"
                anchors.top: readyColumn.top
                anchors.left: readyColumn.left
                anchors.topMargin: 10
                anchors.leftMargin: 10
                height: 18
                font.pointSize: 12
                color: Qt.rgba(0.5, 0.5, 0.5, 1)
            }

            DropArea {
                anchors.fill: parent
                onDropped: {
                    var originalIndexSource = drag.source.parent.mod.getOriginalIndex(drag.source.dragItemIndex)
                    var localIndexSource = drag.source.dragItemIndex
                    drag.source.parent.mod.setStatus(drag.source.dragItemIndex, kanbanBoardModelReady.getStatus())
                    kanbanBoardModelReady.resetModel()
                    drag.source.parent.mod.resetModel()
                }
            }

            ListView {
                id: listReadys
                anchors.top: readyText.bottom
                anchors.left: readyColumn.left
                anchors.right: readyColumn.right
                anchors.topMargin: 10
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 10
                model: kanbanBoardModelReady
                height: Math.min(listReadys.count * (80 + 10), root.height - 90)
                clip: true

                property Item dragParent: dragContainerReady

                delegate:Item {
                    id: delegateItem
                    width:listReadys.width
                    height: 80

                    Rectangle {
                        id: dragRectReady
                        gradient: QQ215.Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: "#343437" }
                            GradientStop { position: 1.0; color: "#222222" }
                        }
                        height: 80
                        width: listReadys.width
                        radius: 5
                        opacity: 0.9

                        property int dragItemIndex: index

                        Rectangle {
                            id: colorBarRect
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            width: parent.width / 20
                            color: "transparent"
                            Rectangle {
                                id: colorBar
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                anchors.right: parent.right
                                color: find(colorModel, function(item) { return item.key === mycolor }).col
                                width: parent.width / 4
                            }
                        }

                        Rectangle {
                            id: contentRect
                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.left: colorBarRect.right
                            anchors.bottom: parent.bottom
                            color: "transparent"

                            Text {
                                text: title
                                color: "white"
                                font.pixelSize: 16
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 10
                                width: parent.width * 0.8
                                elide: Text.ElideRight
                                wrapMode: Text.WordWrap
                            }
                            Text {
                                text: deadline
                                color: "#ff5252"
                                font.pixelSize: 16
                                enabled: deadline.length > 0
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                anchors.rightMargin: 10
                                anchors.bottomMargin: 5
                            }
                            Image {
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.topMargin: 8
                                anchors.rightMargin: 10
                                width: 18
                                height: 18
                                source: isReady ? "icons/success.png" : "icons/processing.png"
                            }
                        }
                        MouseArea {
                            id: mouseAreaReady
                            anchors.fill: parent
                            drag.target: dragRectReady

                            onClicked: {
                                newTaskDialog.titleText = title
                                newTaskDialog.descriptionText = description
                                newTaskDialog.dueDateText = deadline
                                newTaskDialog.selectedColor = mycolor
                                newTaskDialog.isReady = isReady
                                newTaskDialog.createdDate = createdDate
                                newTaskDialog.doneDate = doneDate
                                newTaskDialog.runDialog(1, kanbanBoardModelReady.getOriginalIndex(index))
                            }

                            drag.onActiveChanged: {
                                if (mouseAreaReady.drag.active) {
                                    dragRectReady.dragItemIndex = index;
                                }
                                dragRectReady.Drag.drop();
                            }
                        }
                        states: [
                            State {
                                when: dragRectReady.Drag.active
                                ParentChange {
                                    target: dragRectReady
                                    parent: listReadys.dragParent
                                }

                                AnchorChanges {
                                    target: dragRectReady
                                    anchors.horizontalCenter: undefined
                                    anchors.verticalCenter: undefined
                                }
                            }
                        ]
                        Drag.active: mouseAreaReady.drag.active
                        Drag.hotSpot.x: dragRectReady.width / 2
                        Drag.hotSpot.y: dragRectReady.height / 2
                    }
                    DropArea {
                        anchors.fill: parent
                        onDropped: {
                            var originalIndexSource = drag.source.parent.mod.getOriginalIndex(drag.source.dragItemIndex)
                            var originalIndexTarget = kanbanBoardModelReady.getOriginalIndex(dragRectReady.dragItemIndex)
                            var localIndexSource = drag.source.dragItemIndex
                            var localIndexTarget = dragRectReady.dragItemIndex
                            drag.source.parent.mod.setStatus(drag.source.dragItemIndex, kanbanBoardModelReady.getStatus())
                            kanbanBoardModelReady.addByDrop(originalIndexSource, originalIndexTarget, localIndexSource, localIndexTarget)
                            drag.source.parent.mod.resetModel()
                        }
                    }
                }

            }
        }
        // --------------------------------------------------------------------------------------------------

        // doing-column
        // it is not possible, to create a separate file for that, so every colum is defined in main.qml
        // --------------------------------------------------------------------------------------------
        Rectangle {
            id: doingColumn
            anchors.top: parent.top
            anchors.left: readyColumn.right
            anchors.topMargin: 15
            anchors.leftMargin: 15
            anchors.bottomMargin: 15
            opacity: 0.9
            gradient: QQ215.Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "#1e1f21" }
                GradientStop { position: 1.0; color: "#222326" }
            }
            width: (parent.width - toolbar.width) / 4 - 15
            height: listDoings.height + doingText.height + 40
            radius: 5

            Text {
                id: doingText
                text: "Doing"
                anchors.top: doingColumn.top
                anchors.left: doingColumn.left
                anchors.topMargin: 10
                anchors.leftMargin: 10
                height: 18
                font.pointSize: 12
                color: Qt.rgba(0.5, 0.5, 0.5, 1)
            }

            DropArea {
                anchors.fill: parent
                onDropped: {
                    var originalIndexSource = drag.source.parent.mod.getOriginalIndex(drag.source.dragItemIndex)
                    var localIndexSource = drag.source.dragItemIndex
                    drag.source.parent.mod.setStatus(drag.source.dragItemIndex, kanbanBoardModelDoing.getStatus())
                    kanbanBoardModelDoing.resetModel()
                    drag.source.parent.mod.resetModel()
                }
            }

            ListView {
                id: listDoings
                anchors.top: doingText.bottom
                anchors.left: doingColumn.left
                anchors.right: doingColumn.right
                anchors.topMargin: 10
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 10
                model: kanbanBoardModelDoing
                height: Math.min(listDoings.count * (80 + 10), root.height - 90)
                clip: true

                property Item dragParent: dragContainerDoing

                delegate:Item {
                    id: delegateItem
                    width:listDoings.width
                    height: 80

                    Rectangle {
                        id: dragRectDoing
                        gradient: QQ215.Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: "#343437" }
                            GradientStop { position: 1.0; color: "#222222" }
                        }
                        height: 80
                        width: listDoings.width
                        radius: 5
                        opacity: 0.9

                        property int dragItemIndex: index

                        Rectangle {
                            id: colorBarRect
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            width: parent.width / 20
                            color: "transparent"
                            Rectangle {
                                id: colorBar
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                anchors.right: parent.right
                                color: find(colorModel, function(item) { return item.key === mycolor }).col
                                width: parent.width / 4
                            }

                        }

                        Rectangle {
                            id: contentRect
                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.left: colorBarRect.right
                            anchors.bottom: parent.bottom
                            color: "transparent"

                            Text {
                                text: title
                                color: "white"
                                font.pixelSize: 16
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 10
                                anchors.right: parent.right
                                elide: Text.ElideRight
                                wrapMode: Text.WordWrap
                            }
                            Text {
                                text: deadline
                                color: "#ff5252"
                                font.pixelSize: 16
                                enabled: deadline.length > 0
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                anchors.rightMargin: 10
                                anchors.bottomMargin: 5
                            }
                            Image {
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.topMargin: 8
                                anchors.rightMargin: 10
                                width: 18
                                height: 18
                                source: isReady ? "icons/success.png" : "icons/processing.png"
                            }
                        }
                        MouseArea {
                            id: mouseAreaDoing
                            anchors.fill: parent
                            drag.target: dragRectDoing

                            onClicked: {
                                newTaskDialog.titleText = title
                                newTaskDialog.descriptionText = description
                                newTaskDialog.dueDateText = deadline
                                newTaskDialog.selectedColor = mycolor
                                newTaskDialog.isReady = isReady
                                newTaskDialog.createdDate = createdDate
                                newTaskDialog.doneDate = doneDate
                                newTaskDialog.runDialog(1, kanbanBoardModelDoing.getOriginalIndex(index))
                            }

                            drag.onActiveChanged: {
                                if (mouseAreaDoing.drag.active) {
                                    dragRectDoing.dragItemIndex = index;
                                }
                                dragRectDoing.Drag.drop();
                            }
                        }
                        states: [
                            State {
                                when: dragRectDoing.Drag.active
                                ParentChange {
                                    target: dragRectDoing
                                    parent: listDoings.dragParent
                                }

                                AnchorChanges {
                                    target: dragRectDoing
                                    anchors.horizontalCenter: undefined
                                    anchors.verticalCenter: undefined
                                }
                            }
                        ]
                        Drag.active: mouseAreaDoing.drag.active
                        Drag.hotSpot.x: dragRectDoing.width / 2
                        Drag.hotSpot.y: dragRectDoing.height / 2
                    }
                    DropArea {
                        anchors.fill: parent
                        onDropped: {
                            var originalIndexSource = drag.source.parent.mod.getOriginalIndex(drag.source.dragItemIndex)
                            var originalIndexTarget = kanbanBoardModelDoing.getOriginalIndex(dragRectDoing.dragItemIndex)
                            var localIndexSource = drag.source.dragItemIndex
                            var localIndexTarget = dragRectDoing.dragItemIndex
                            drag.source.parent.mod.setStatus(drag.source.dragItemIndex, kanbanBoardModelDoing.getStatus())
                            kanbanBoardModelDoing.addByDrop(originalIndexSource, originalIndexTarget, localIndexSource, localIndexTarget)
                            drag.source.parent.mod.resetModel()
                        }
                    }
                }

            }
        }
        // --------------------------------------------------------------------------------------------------
        //
        //
        // done-column
        // it is not possible, to create a separate file for that, so every colum is defined in main.qml
        // --------------------------------------------------------------------------------------------
        Rectangle {
            id: doneColumn
            anchors.top: parent.top
            anchors.left: doingColumn.right
            anchors.topMargin: 15
            anchors.leftMargin: 15
            anchors.bottomMargin: 15
            opacity: 0.9
            gradient: QQ215.Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "#1e1f21" }
                GradientStop { position: 1.0; color: "#222326" }
            }
            width: (parent.width - toolbar.width) / 4 - 30
            height: listDones.height + doneText.height + 40
            radius: 5

            Text {
                id: doneText
                text: "Done"
                anchors.top: doneColumn.top
                anchors.left: doneColumn.left
                anchors.topMargin: 10
                anchors.leftMargin: 10
                height: 18
                font.pointSize: 12
                color: Qt.rgba(0.5, 0.5, 0.5, 1)
            }

            DropArea {
                anchors.fill: parent
                onDropped: {
                    var originalIndexSource = drag.source.parent.mod.getOriginalIndex(drag.source.dragItemIndex)
                    var localIndexSource = drag.source.dragItemIndex
                    drag.source.parent.mod.setStatus(drag.source.dragItemIndex, kanbanBoardModelDone.getStatus())
                    kanbanBoardModelDone.resetModel()
                    drag.source.parent.mod.resetModel()
                }
            }

            ListView {
                id: listDones
                anchors.top: doneText.bottom
                anchors.left: doneColumn.left
                anchors.right: doneColumn.right
                anchors.topMargin: 10
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 10
                model: kanbanBoardModelDone
                height: Math.min(listDones.count * (80 + 10), root.height - 90)
                clip: true

                property var dragParent: dragContainerDone

                delegate:Item {
                    id: delegateItem
                    width:listDones.width
                    height: 80

                    Rectangle {
                        id: dragRectDone
                        gradient: QQ215.Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: "#343437" }
                            GradientStop { position: 1.0; color: "#222222" }
                        }
                        height: 80
                        width: listDones.width
                        radius: 5
                        opacity: 0.9

                        property int dragItemIndex: index

                        Rectangle {
                            id: colorBarRect
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            width: parent.width / 20
                            color: "transparent"
                            Rectangle {
                                id: colorBar
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                anchors.right: parent.right
                                color: find(colorModel, function(item) { return item.key === mycolor }).col
                                width: parent.width / 4
                            }

                        }

                        Rectangle {
                            id: contentRect
                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.left: colorBarRect.right
                            anchors.bottom: parent.bottom
                            color: "transparent"

                            Text {
                                text: title
                                color: "white"
                                font.pixelSize: 16
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 10
                                anchors.right: parent.right
                                elide: Text.ElideRight
                                wrapMode: Text.WordWrap
                            }
                            Text {
                                text: deadline
                                color: "#ff5252"
                                font.pixelSize: 16
                                enabled: deadline.length > 0
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                anchors.rightMargin: 10
                                anchors.bottomMargin: 5
                            }
                        }
                        MouseArea {
                            id: mouseAreaDone
                            anchors.fill: parent
                            drag.target: dragRectDone

                            onClicked: {
                                newTaskDialog.titleText = title
                                newTaskDialog.descriptionText = description
                                newTaskDialog.dueDateText = deadline
                                newTaskDialog.selectedColor = mycolor
                                newTaskDialog.isReady = isReady
                                newTaskDialog.createdDate = createdDate
                                newTaskDialog.doneDate = doneDate
                                newTaskDialog.runDialog(1, kanbanBoardModelDone.getOriginalIndex(index))
                            }

                            drag.onActiveChanged: {
                                if (mouseAreaDone.drag.active) {
                                    dragRectDone.dragItemIndex = index;
                                }
                                dragRectDone.Drag.drop();
                            }
                        }
                        states: [
                            State {
                                when: dragRectDone.Drag.active
                                ParentChange {
                                    target: dragRectDone
                                    parent: listDones.dragParent
                                }

                                AnchorChanges {
                                    target: dragRectDone
                                    anchors.horizontalCenter: undefined
                                    anchors.verticalCenter: undefined
                                }
                            }
                        ]
                        Drag.active: mouseAreaDone.drag.active
                        Drag.hotSpot.x: dragRectDone.width / 2
                        Drag.hotSpot.y: dragRectDone.height / 2
                    }
                    DropArea {
                        anchors.fill: parent
                        onDropped: {
                            var originalIndexSource = drag.source.parent.mod.getOriginalIndex(drag.source.dragItemIndex)
                            var originalIndexTarget = kanbanBoardModelDone.getOriginalIndex(dragRectDone.dragItemIndex)
                            var localIndexSource = drag.source.dragItemIndex
                            var localIndexTarget = dragRectDone.dragItemIndex
                            drag.source.parent.mod.setStatus(drag.source.dragItemIndex, kanbanBoardModelDone.getStatus())
                            kanbanBoardModelDone.addByDrop(originalIndexSource, originalIndexTarget, localIndexSource, localIndexTarget)
                            drag.source.parent.mod.resetModel()
                        }
                    }
                }

            }
        }

        //
        // --------------------------------------------------------------------------------------------------
        //
        //                                      ADD NEW DIALOG
        //
        // --------------------------------------------------------------------------------------------------
        //

        Dialog {
            id: newTaskDialog
            height: 600
            width: 800
            x: (parent.width - width) / 2
            y: (parent.height - height) / 2

            property alias titleText: taskNameField.text
            property alias descriptionText: noteText.text
            property alias dueDateText: textDate.text
            property var selectedColor: 0

            property int startArgument: -1
            property int itemIndex: -1
            property bool isReady: false

            // internal date
            property string createdDate: ""
            property string doneDate: ""

            function runDialog(arg: int, itemIndex: int) {
                newTaskDialog.startArgument = arg;
                newTaskDialog.itemIndex = itemIndex
                control.buttonSelectedColor = find(colorModel, function(item) { return item.key === newTaskDialog.selectedColor }).col;
                newTaskDialog.open()
            }

            Rectangle {
                id: newTaskRect
                height: newTaskDialog.height
                width: newTaskDialog.width
                x: (parent.width - width) / 2
                y: (parent.height - height) / 2
                color: "#232323"
                border.width: 1
                border.color: "darkgrey" 

                ColumnLayout {
                    id: topColumn
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 30
                    spacing: 20

                    // Header
                    Rectangle  {
                        height: 50;
                        width: parent.width
                        color: "transparent"

                        Label {
                            text: "Edit task"
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            color: "white"
                            font.pointSize: 12
                        }

                        Button {
                            id: buttonCancelItem
                            height: textDate.height
                            width: 66
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter

                            background: Rectangle { color: "transparent"; border.width: 1; border.color: "darkgrey"; radius: 3; }
                            Text {
                                anchors.fill: parent
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: 10
                                color: "#FFFFFF"
                                text: "DELETE"
                                font.bold: true
                            }

                            onPressAndHold: {
                                if (newTaskDialog.startArgument > 0)
                                    root.itemDelete(newTaskDialog.itemIndex)
                                newTaskDialog.close();
                            }
                        }
                    }

                    // Task name
                    Rectangle  {
                        height: 30;
                        width: parent.width
                        color: "transparent"

                        TextField {
                            id: taskNameField
                            x: .3*parent.width
                            width: .65*parent.width
                            anchors.fill: parent
                            color: "white"
                            font.pointSize: 10
                            background: Rectangle { color: "#232323"; border.width: 1; border.color: "darkgrey"; }
                        }
                    }

                    // Due Date
                    Rectangle  {
                        height: 30;
                        width: parent.width
                        color: "transparent"
                        
                        // Color Selection
                        Rectangle {
                            height: 30;
                            width: parent.width - textDate.width - 10
                            color: "transparent"
                            anchors.left: textDate.right
                            anchors.leftMargin: 20
                            Button {
                                id: control
                                property bool showColors: false
                                property var buttonSelectedColor: find(colorModel, function(item) { return item.key === 0 }).col
                                background: Rectangle {
                                    implicitWidth: 30
                                    implicitHeight: 30
                                    opacity: enabled ? 1 : 0.3
                                    color: control.buttonSelectedColor
                                    radius: 15
                                }
                                onClicked: showColors = !showColors
                            }

                            ListView {
                                id: listColors
                                model: colorModel
                                anchors.left: control.right
                                anchors.right: parent.right
                                anchors.leftMargin: 10
                                height: 30
                                orientation: ListView.Horizontal
                                visible: control.showColors
                                spacing: 10

                                delegate: Item {
                                    id: delegateItem
                                    width: 30
                                    height: 30

                                    Rectangle {
                                        anchors.fill: parent
                                        radius: 15
                                        color: col
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            newTaskDialog.selectedColor = key;
                                            control.buttonSelectedColor = find(colorModel, function(item) { return item.key === key }).col;
                                            control.showColors = false
                                        }
                                    }
                                }
                            } // end listColors
                        } // end color selection

                        Image {
                            id: readySetting
                            source: newTaskDialog.isReady ? "icons/success.png" : "icons/processing.png"
                            anchors.right: parent.right
                            height: 30;
                            width: 30
                            MouseArea {
                              anchors.fill: parent
                              onClicked: newTaskDialog.isReady = !newTaskDialog.isReady
                            }
                        }

                        TextField {
                            id: textDate
                            width: 175
                            anchors.verticalCenter: parent.verticalCenter
                            color: "white"
                            font.pointSize: 10
                            readOnly: true
                            background: Rectangle { color: "#232323"; border.width: 1;  border.color: "darkgrey" }
                            Button {
                                id: button
                                height: textDate.height
                                width: 75
                                anchors.right: textDate.right
                                anchors.verticalCenter: textDate.verticalCenter
                                background: Rectangle { color: "#7d8591"; border.width: 1;  border.color: "darkgrey" }
                                Text {
                                    anchors.fill: parent
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font.pixelSize: 10
                                    text: "DUE DATE"
                                    font.bold: true
                                }
                                onClicked: {
                                    cal.visible = true
                                }
                            }
                        }
                    }
                } // end topColumn

                // Note Label
                Rectangle  {
                    id: noteRect
                    anchors.top: topColumn.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: buttonBar.top
                    anchors.margins: 30
                    color: "transparent"

                    Label {
                        id: noteLabel
                        text: "Note:"
                        anchors.top: parent.top
                        anchors.left: parent.left
                        color: "white"
                        font.pointSize: 10
                    }

                    ScrollView {
                        id: view
                        anchors.top: noteLabel.bottom
                        anchors.bottom: parent.bottom
                        anchors.topMargin: 10
                        width: parent.width
                        TextArea {
                            id: noteText
                            wrapMode: TextEdit.WordWrap
                            text: ""
                            color: "white"
                            font.pointSize: 10
                            background: Rectangle { color: "#232323"; border.width: 1;  border.color: "darkgrey" }
                        }
                    }
                }

                Rectangle {
                    id: buttonBar
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: 30
                    height: 40
                    color: "transparent"

                    Row {
                        spacing: 10
                        anchors.horizontalCenter: parent.horizontalCenter
                        Button {
                            id: buttonSave
                            height: textDate.height
                            width: 66
                            background: Rectangle { color: "transparent"; border.width: 1; border.color: "firebrick"; radius: 3; }
                            Text {
                                anchors.fill: parent
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: 10
                                color: "firebrick"
                                text: "SAVE"
                                font.bold: true
                            }
                            onClicked: {
                                root.itemDataChange(newTaskDialog.startArgument, newTaskDialog.itemIndex, taskNameField.text, noteText.text, textDate.text, newTaskDialog.selectedColor, newTaskDialog.isReady);
                                newTaskDialog.close()
                            }
                        }
                        Button {
                            id: buttonCancel
                            height: textDate.height
                            width: 66
                            background: Rectangle { color: "transparent"; border.width: 1; border.color: "darkgrey"; radius: 3; }
                            Text {
                                anchors.fill: parent
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: 10
                                color: "#FFFFFF"
                                text: "CANCEL"
                                font.bold: true
                            }

                            onClicked: {
                                newTaskDialog.close();
                            }

                            onPressAndHold: {
                                if(newTaskDialog.startArgument == 1) {
                                    statisticsDialog.itemIndex = newTaskDialog.itemIndex;
                                    statisticsDialog.createdDateText = newTaskDialog.createdDate;
                                    statisticsDialog.doneDateText = newTaskDialog.doneDate;
                                    statisticsDialog.open();
                                }
                            }
                        }
                    }
                }

                QQC1.Calendar {
                    id:cal
                    anchors.horizontalCenter: newTaskRect.horizontalCenter
                    anchors.verticalCenter: newTaskRect.verticalCenter
                    width: 220
                    height: 205
                    visible: false
                    selectedDate: new Date()
                    onClicked:  {
                        textDate.text=Qt.formatDate(cal.selectedDate, "dd/MM/yyyy");
                        cal.visible=false
                    }
                }

            }
        }
        //  ---------------------------- End Edit Dialog ------------------------------------------------

        //
        // --------------------------------------------------------------------------------------------------
        //
        //                                      EDIT STATISTICS DIALOG
        //
        // --------------------------------------------------------------------------------------------------
        //

        Dialog {
            id: statisticsDialog
            height: 300
            width: 400
            x: (parent.width - width) / 2
            y: (parent.height - height) / 2

            property alias createdDateText: createdDate.text 
            property alias doneDateText: doneDate.text 
            property int itemIndex: -1

            Rectangle {
                id: statisticsRect
                height: statisticsDialog.height
                width: statisticsDialog.width
                x: (parent.width - width) / 2
                y: (parent.height - height) / 2
                color: "#232323"
                border.width: 1
                border.color: "darkgrey" 

                ColumnLayout {
                    id: topColumnStat
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 30
                    spacing: 20

                    // Header
                    Rectangle  {
                        height: 50;
                        width: parent.width
                        color: "transparent"

                        Label {
                            text: "Task Dates"
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            color: "white"
                            font.pointSize: 12
                        }
                    }
                  
                    // Created Date
                    Rectangle  {
                        height: 30;
                        width: parent.width
                        color: "transparent"

                        TextField {
                            id: createdDate 
                            width: 200
                            anchors.verticalCenter: parent.verticalCenter
                            color: "white"
                            font.pointSize: 10
                            readOnly: true
                            background: Rectangle { color: "#232323"; border.width: 1;  border.color: "darkgrey" }
                            Button {
                                height: createdDate.height
                                width: 100
                                anchors.right: createdDate.right
                                anchors.verticalCenter: createdDate.verticalCenter
                                background: Rectangle { color: "#7d8591"; border.width: 1;  border.color: "darkgrey" }
                                Text {
                                    anchors.fill: parent
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font.pixelSize: 10
                                    text: "CREATED DATE"
                                    font.bold: true
                                }
                                onClicked: {
                                    statisticsDateCalendar.runStatisticsCalendar("created")
                                }
                            }
                        }
                    }

                    // Done Date
                    Rectangle  {
                        height: 30;
                        width: parent.width
                        color: "transparent"

                        TextField {
                            id: doneDate 
                            width: 200
                            anchors.verticalCenter: parent.verticalCenter
                            color: "white"
                            font.pointSize: 10
                            readOnly: true
                            background: Rectangle { color: "#232323"; border.width: 1;  border.color: "darkgrey" }
                            Button {
                                height: doneDate.height
                                width: 100
                                anchors.right: doneDate.right
                                anchors.verticalCenter: doneDate.verticalCenter
                                background: Rectangle { color: "#7d8591"; border.width: 1;  border.color: "darkgrey" }
                                Text {
                                    anchors.fill: parent
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font.pixelSize: 10
                                    text: "DONE DATE"
                                    font.bold: true
                                }
                                onClicked: {
                                    statisticsDateCalendar.runStatisticsCalendar("done")
                                }
                            }
                        }
                    }
                }

                QQC1.Calendar {
                    id: statisticsDateCalendar
                    anchors.horizontalCenter: statisticsDialog.horizontalCenter
                    anchors.verticalCenter: statisticsDialog.verticalCenter
                    width: 220
                    height: 205
                    visible: false
                    selectedDate: new Date()
                    property var dateType : "" 

                    function runStatisticsCalendar(dateType) {
                        statisticsDateCalendar.dateType = dateType;
                        statisticsDateCalendar.visible = true;
                    }            

                    onClicked:  {
                        var selectedDateString = Qt.formatDate(statisticsDateCalendar.selectedDate, "dd/MM/yyyy");

                        if(statisticsDateCalendar.dateType == "created") {
                            createdDate.text = selectedDateString;
                        }
                        else if(statisticsDateCalendar.dateType == "done") {
                            doneDate.text = selectedDateString;
                        }
                        statisticsDateCalendar.visible=false
                    }
                }

                Rectangle {
                    id: buttonBarStat
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: 30
                    height: 40
                    color: "transparent"

                    Row {
                        spacing: 10
                        anchors.horizontalCenter: parent.horizontalCenter
                        Button {
                            id: buttonSaveStat
                            height: 25// textDate.height
                            width: 66
                            background: Rectangle { color: "transparent"; border.width: 1; border.color: "firebrick"; radius: 3; }
                            Text {
                                anchors.fill: parent
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: 10
                                color: "firebrick"
                                text: "SAVE"
                                font.bold: true
                            }
                            onClicked: {
                                root.internalItemDataChange(statisticsDialog.itemIndex, statisticsDialog.createdDateText, statisticsDialog.doneDateText)
                                statisticsDateCalendar.visible=false
                                statisticsDialog.close()
                            }
                        }
                        Button {
                            id: buttonCancelStat
                            height: 25// textDate.height
                            width: 66
                            background: Rectangle { color: "transparent"; border.width: 1; border.color: "darkgrey"; radius: 3; }
                            Text {
                                anchors.fill: parent
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: 10
                                color: "#FFFFFF"
                                text: "CANCEL"
                                font.bold: true
                            }

                            onClicked: {
                                statisticsDateCalendar.visible=false
                                statisticsDialog.close();
                            }
                        }
                    }
                }
              }
        }

        //  ---------------------------- End Statistics Dialog ------------------------------------------------
        
        Popup {
            id: archiveDonesPopup
            height: 200
            width: 400
            x: (parent.width - width) / 2
            y: (parent.height - height) / 2
            modal: true
            focus: true
            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

            Rectangle {
                id: archiveDonesPopupRect
                height: archiveDonesPopup.height
                width: archiveDonesPopup.width
                x: (parent.width - width) / 2
                y: (parent.height - height) / 2
                color: "#232323"
                border.width: 1
                border.color: "darkgrey" 

                ColumnLayout {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 30
                    spacing: 20

                    // Header
                    Rectangle  {
                        height: 50;
                        width: parent.width
                        color: "transparent"

                        Label {
                            text: "Are you sure you want to archive the tasks from the Done column? At the moment you cannot retrieve them."
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            width: parent.width
                            color: "white"
                            font.pointSize: 12
                            wrapMode: Text.WordWrap
                        }
                    }

                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: 30
                    height: 40
                    color: "transparent"

                    Row {
                        spacing: 10
                        anchors.horizontalCenter: parent.horizontalCenter
                        Button {
                            height: 25// textDate.height
                            width: 66
                            background: Rectangle { color: "transparent"; border.width: 1; border.color: "firebrick"; radius: 3; }
                            Text {
                                anchors.fill: parent
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: 10
                                color: "firebrick"
                                text: "YES"
                                font.bold: true
                            }
                            onClicked: {
                                archive();
                                archiveDonesPopup.close();
                            }
                        }

                        Button {
                            height: 25// textDate.height
                            width: 66
                            background: Rectangle { color: "transparent"; border.width: 1; border.color: "darkgrey"; radius: 3; }
                            Text {
                                anchors.fill: parent
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: 10
                                color: "#FFFFFF"
                                text: "NO"
                                font.bold: true
                            }

                            onClicked: {
                                archiveDonesPopup.close();
                            }
                        }
                    }
                }
           }
        }

        // --- Drag item with highes z-Layer to reparent the drag item to it (to ensure the drag item stays on top)
        Item {
            id: dragContainerTodo
            anchors.fill: parent
            property var mod: kanbanBoardModelTodo
        }

        Item {
            id: dragContainerReady
            anchors.fill: parent
            property var mod: kanbanBoardModelReady
        }

        Item {
            id: dragContainerDoing
            anchors.fill: parent
            property var mod: kanbanBoardModelDoing
        }

        Item {
            id: dragContainerDone
            anchors.fill: parent
            property var mod: kanbanBoardModelDone
        }
    }
}
