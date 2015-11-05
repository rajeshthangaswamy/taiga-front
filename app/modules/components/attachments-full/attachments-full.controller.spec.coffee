###
# Copyright (C) 2014-2015 Taiga Agile LLC <taiga@taiga.io>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# File: attchments.controller.spec.coffee
###

describe "AttachmentsController", ->
    $provide = null
    $controller = null
    mocks = {}

    _mockAttachmentsService = ->
        mocks.attachmentsService = {}

        $provide.value("tgAttachmentsService", mocks.attachmentsService)

    _mocks = ->
        module (_$provide_) ->
            $provide = _$provide_

            _mockAttachmentsService()

            return null

    _inject = ->
        inject (_$controller_) ->
            $controller = _$controller_

    _setup = ->
        _mocks()
        _inject()

    beforeEach ->
        module "taigaComponents"

        _setup()

    it "generate, refresh deprecated counter", () ->
        attachments = Immutable.fromJS([
            {is_deprecated: false},
            {is_deprecated: true},
            {is_deprecated: true},
            {is_deprecated: false},
            {is_deprecated: true}
        ])

        ctrl = $controller("Attachments")

        ctrl.attachments = attachments

        ctrl.generate()

        expect(ctrl.deprecatedsCount).to.be.equal(3)

    it "toggle deprecated visibility", () ->
        ctrl = $controller("Attachments")

        ctrl.deprecatedsVisible = false

        ctrl.generate = sinon.spy()

        ctrl.toggleDeprecatedsVisible()

        expect(ctrl.deprecatedsVisible).to.be.true
        expect(ctrl.generate).to.be.calledOnce

    describe "add attachments", () ->
        it "valid attachment", () ->
            file = {
                file: {},
                name: 'test',
                size: 3000
            }

            mocks.attachmentsService.validate = sinon.stub()
            mocks.attachmentsService.validate.withArgs(file).returns(true)

            ctrl = $controller("Attachments")

            ctrl.attachments = Immutable.List()
            ctrl.onAdd = sinon.stub()

            ctrl.addAttachment(file)

            onAdd = sinon.match (value) ->
                attachment = value.attachment.toJS()

                return (
                    attachment.name == file.name &&
                    attachment.size == file.size &&
                    attachment.file.name == file.name &&
                    attachment.file.size == file.size
                )
            , "onAdd"

            expect(ctrl.attachments.count()).to.be.equal(1)
            expect(ctrl.onAdd).to.be.calledWith(onAdd)

        it "invalid attachment", () ->
            file = {
                file: {},
                name: 'test',
                size: 3000
            }

            mocks.attachmentsService.validate = sinon.stub()
            mocks.attachmentsService.validate.withArgs(file).returns(false)

            ctrl = $controller("Attachments")

            ctrl.attachments = Immutable.List()
            ctrl.onAdd = sinon.stub()

            ctrl.addAttachment(file)

            expect(ctrl.attachments.count()).to.be.equal(0)
            expect(ctrl.onAdd).not.to.be.called;


    it "add attachments", () ->
        ctrl = $controller("Attachments")

        ctrl.attachments = Immutable.List()
        ctrl.addAttachment = sinon.spy()

        files = [
            {},
            {},
            {}
        ]

        ctrl.addAttachments(files)

        expect(ctrl.addAttachment).to.have.callCount(3)

    it "delete attachment", () ->
        ctrl = $controller("Attachments")

        ctrl.onDelete = sinon.spy()
        ctrl.attachments = Immutable.fromJS([
            {id: 1},
            {id: 2},
            {id: 3},
            {id: 4}
        ])

        deleteFile = ctrl.attachments.get(1)

        onDelete = sinon.match (value) ->
            return value.attachment == deleteFile
        , "onDelete"

        ctrl.deleteAttachment(deleteFile)

        expect(ctrl.attachments.count()).to.be.equal(3)
        expect(ctrl.onDelete).to.be.calledWith(onDelete)

    it "reorder attachments", () ->
        attachments = Immutable.fromJS([
            {id: 0, is_deprecated: false, order: 0},
            {id: 1, is_deprecated: true, order: 1},
            {id: 2, is_deprecated: true, order: 2},
            {id: 3, is_deprecated: false, order: 3},
            {id: 4, is_deprecated: true, order: 4}
        ])

        ctrl = $controller("Attachments")

        ctrl.attachments = attachments

        ctrl.reorderAttachment(attachments.get(1), 0)

        expect(ctrl.attachments.get(0)).to.be.equal(attachments.get(1))


    it "update attachment", () ->
        attachments = Immutable.fromJS([
            {id: 0, is_deprecated: false, order: 0},
            {id: 1, is_deprecated: true, order: 1},
            {id: 2, is_deprecated: true, order: 2},
            {id: 3, is_deprecated: false, order: 3},
            {id: 4, is_deprecated: true, order: 4}
        ])

        attachment = attachments.get(1)
        attachment = attachment.set('is_deprecated', false)

        ctrl = $controller("Attachments")

        ctrl.attachments = attachments

        ctrl.updateAttachment(attachment, 0)

        expect(ctrl.attachments.get(1).toJS()).to.be.eql(attachment.toJS())
