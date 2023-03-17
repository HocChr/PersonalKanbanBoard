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

    visibility: "Maximized"
    flags: Qt.Window

    signal itemDataChange(var runArgs, var itemIndex, var title, var description, var deadline, var col, var isReady);
    signal itemDelete(var itemIndex);

    ListModel {
        id: colorModel
        ListElement { name: "white"; col: "white"; key: 0 }
        ListElement { name: "black"; col: "black"; key: 1 }
        ListElement { name: "red"; col: "#ff5252"; key: 2  }
        ListElement { name: "blue"; col: "#5252ff"; key: 3  }
        ListElement { name: "green"; col: "#60ff52"; key: 4  }
        ListElement { name: "yellow"; col: "#fcff52"; key: 5  }
    }

    function find(model, criteria) {
        for(var i = 0; i < model.count; ++i) if (criteria(model.get(i))) return model.get(i)
        return null
    }

    onItemDataChange: {
        if(runArgs == 0) {
            kanbanBoardModelTodo.addData(title, description, deadline, col, isReady)
        }
        else if(runArgs == 1) {
            kanbanBoardModelTodo.changeData(itemIndex, title, description, deadline, col, isReady);
            kanbanBoardModelReady.changeData(itemIndex, title, description, deadline, col, isReady);
            kanbanBoardModelDoing.changeData(itemIndex, title, description, deadline, col, isReady);
            kanbanBoardModelDone.changeData(itemIndex, title, description, deadline, col, isReady);
        }
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


    Rectangle {
        anchors.fill: parent

        Rectangle {
            id: background
            anchors.fill: parent
            color: Qt.rgba(0.1, 0.1, 0.1, 1)
        }
        
        Rectangle {
            id: toolbar
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            color: "#222222"
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
                    newTaskDialog.runDialog(0, 0)
                }
            }

            Button {
                id: strategicButton
                anchors.top: buttonAddTask.bottom
                anchors.left: toolbar.left
                anchors.right: toolbar.right
                anchors.topMargin: 25
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
                anchors.topMargin: 15
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
            anchors.bottom: parent.bottom
            anchors.left: toolbar.right
            anchors.topMargin: 15
            anchors.leftMargin: 15
            anchors.bottomMargin: 15
            gradient: QQ215.Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "#1e1f21" }
                GradientStop { position: 1.0; color: "#222326" }
            }
            width: (parent.width - toolbar.width) / 4 - 15
            radius: 15

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
                anchors.bottom: todoColumn.bottom
                anchors.right: todoColumn.right
                anchors.topMargin: 10
                anchors.leftMargin: 10
                anchors.bottomMargin: 10
                anchors.rightMargin: 10
                spacing: 10
                model: kanbanBoardModelTodo

                property Item dragParent: dragContainerTodo

                delegate: Item {
                    id: delegateItem
                    width: listTodos.width
                    height: 60
                    Rectangle {
                        id: dragRectTodo
                        gradient: QQ215.Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: "#343437" }
                            GradientStop { position: 1.0; color: "#3d3d40" }
                        }
                        height: 60
                        width: listTodos.width

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
                                font.pixelSize: 12
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 10
                                anchors.right: parent.right
                                elide: Text.ElideRight
                            }
                            Text {
                                text: deadline
                                color: "firebrick"
                                font.pixelSize: 12
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
            anchors.bottom: parent.bottom
            anchors.left: todoColumn.right
            anchors.topMargin: 15
            anchors.leftMargin: 15
            anchors.bottomMargin: 15
            gradient: QQ215.Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "#1e1f21" }
                GradientStop { position: 1.0; color: "#222326" }
            }
            width: (parent.width - toolbar.width) / 4 - 15
            radius: 15

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
                anchors.bottom: readyColumn.bottom
                anchors.right: readyColumn.right
                anchors.topMargin: 10
                anchors.leftMargin: 10
                anchors.bottomMargin: 10
                anchors.rightMargin: 10
                spacing: 10
                model: kanbanBoardModelReady

                property Item dragParent: dragContainerReady

                delegate:Item {
                    id: delegateItem
                    width:listReadys.width
                    height: 60

                    Rectangle {
                        id: dragRectReady
                        gradient: QQ215.Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: "#343437" }
                            GradientStop { position: 1.0; color: "#3d3d40" }
                        }
                        height: 60
                        width: listReadys.width

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
                                font.pixelSize: 12
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 10
                                anchors.right: parent.right
                                elide: Text.ElideRight
                            }
                            Text {
                                text: deadline
                                color: "firebrick"
                                font.pixelSize: 12
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
                                width: 15
                                height: 15
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
            anchors.bottom: parent.bottom
            anchors.left: readyColumn.right
            anchors.topMargin: 15
            anchors.leftMargin: 15
            anchors.bottomMargin: 15
            gradient: QQ215.Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "#1e1f21" }
                GradientStop { position: 1.0; color: "#222326" }
            }
            width: (parent.width - toolbar.width) / 4 - 15
            radius: 15

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
                anchors.bottom: doingColumn.bottom
                anchors.right: doingColumn.right
                anchors.topMargin: 10
                anchors.leftMargin: 10
                anchors.bottomMargin: 10
                anchors.rightMargin: 10
                spacing: 10
                model: kanbanBoardModelDoing

                property Item dragParent: dragContainerDoing

                delegate:Item {
                    id: delegateItem
                    width:listDoings.width
                    height: 60

                    Rectangle {
                        id: dragRectDoing
                        gradient: QQ215.Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: "#343437" }
                            GradientStop { position: 1.0; color: "#3d3d40" }
                        }
                        height: 60
                        width: listDoings.width

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
                                font.pixelSize: 12
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 10
                                anchors.right: parent.right
                                elide: Text.ElideRight
                            }
                            Text {
                                text: deadline
                                color: "firebrick"
                                font.pixelSize: 12
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
                                width: 15
                                height: 15
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
            anchors.bottom: parent.bottom
            anchors.left: doingColumn.right
            anchors.topMargin: 15
            anchors.leftMargin: 15
            anchors.bottomMargin: 15
            gradient: QQ215.Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "#1e1f21" }
                GradientStop { position: 1.0; color: "#222326" }
            }
            width: (parent.width - toolbar.width) / 4 - 30
            radius: 15

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
                anchors.bottom: doneColumn.bottom
                anchors.right: doneColumn.right
                anchors.topMargin: 10
                anchors.leftMargin: 10
                anchors.bottomMargin: 10
                anchors.rightMargin: 10
                spacing: 10
                model: kanbanBoardModelDone

                property var dragParent: dragContainerDone

                delegate:Item {
                    id: delegateItem
                    width:listDones.width
                    height: 60

                    Rectangle {
                        id: dragRectDone
                        gradient: QQ215.Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: "#343437" }
                            GradientStop { position: 1.0; color: "#3d3d40" }
                        }
                        height: 60
                        width: listDones.width

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
                                font.pixelSize: 12
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 10
                                anchors.right: parent.right
                                elide: Text.ElideRight
                            }
                            Text {
                                text: deadline
                                color: "firebrick"
                                font.pixelSize: 12
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
                border.width: 0

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

                            onClicked: {
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
