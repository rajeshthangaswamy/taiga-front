sizeFormat = @.taiga.sizeFormat

class AttachmentsService
    @.$inject = [
        "$tgConfirm",
        "$tgConfig",
        "$translate",
        "tgResources"
    ]

    constructor: (@confirm, @config, @translate, @rs) ->
        @.maxFileSize = @.getMaxFileSize()

        if @.maxFileSize
            @.maxFileSizeFormated = sizeFormat(@.maxFileSize)

    sizeError: (file) ->
        message = @translate.instant("ATTACHMENT.ERROR_MAX_SIZE_EXCEEDED", {
            fileName: file.name,
            fileSize: sizeFormat(file.size),
            maxFileSize: @.maxFileSizeFormated
        })

        @confirm.notify("error", message)

    validate: (file) ->
        return true
        if @.maxFileSize && file.size > @.maxFileSize
            @.sizeError(file)

            return false

        return true

    getMaxFileSize: () ->
        return @config.get("maxUploadFileSize", null)

    list: (type, objId, projectId) ->
        return @rs.attachments.list(type, objId, projectId).then (attachments) =>
            return attachments.sortBy (attachment) => attachment.get('order')

    delete: (type, id) ->
        return @rs.attachments.delete(type, id)

    saveError: (file, data) ->
        message = ""

        if file
            message = @translate.instant("ATTACHMENT.ERROR_UPLOAD_ATTACHMENT", {
                        fileName: file.name, errorMessage: data.data._error_message
                      })

        @confirm.notify("error", message)

    upload: (file, objId, projectId, type) ->
        promise = @rs.attachments.create(type, projectId, objId, file)

        promise.then null, @.saveError.bind(this, file)

        return promise

    patch: (id, type, patch) ->
        promise = @rs.attachments.patch(type, id, patch)

        promise.then null, @.saveError.bind(this, null)

        return promise

angular.module("taigaCommon").service("tgAttachmentsService", AttachmentsService)
