//
//  Copyright (c) 2019 Open Whisper Systems. All rights reserved.
//

#import "OWSUnknownProtocolVersionMessage.h"
#import <SignalServiceKit/ContactsManagerProtocol.h>
#import <SignalServiceKit/SSKEnvironment.h>
#import <SignalServiceKit/SignalServiceKit-Swift.h>

NS_ASSUME_NONNULL_BEGIN

@interface OWSUnknownProtocolVersionMessage ()

@property (nonatomic) NSUInteger protocolVersion;
// If nil, the invalid message was sent by a linked device.
@property (nonatomic, nullable) NSString *senderId;

@end

#pragma mark -

@implementation OWSUnknownProtocolVersionMessage

- (id<ContactsManagerProtocol>)contactsManager
{
    return SSKEnvironment.shared.contactsManager;
}

- (instancetype)initWithTimestamp:(uint64_t)timestamp
                           thread:(TSThread *)thread
                         senderId:(nullable NSString *)senderId
                  protocolVersion:(NSUInteger)protocolVersion
{
    self = [super initWithTimestamp:timestamp inThread:thread messageType:TSInfoMessageUnknownProtocolVersion];

    if (self) {
        OWSAssertDebug(senderId.length > 0);

        _protocolVersion = protocolVersion;
        _senderId = senderId;
    }

    return self;
}

// --- CODE GENERATION MARKER

// This snippet is generated by /Scripts/sds_codegen/sds_generate.py. Do not manually edit it, instead run
// `sds_codegen.sh`.

// clang-format off

- (instancetype)initWithUniqueId:(NSString *)uniqueId
             receivedAtTimestamp:(uint64_t)receivedAtTimestamp
                          sortId:(uint64_t)sortId
                       timestamp:(uint64_t)timestamp
                  uniqueThreadId:(NSString *)uniqueThreadId
                   attachmentIds:(NSArray<NSString *> *)attachmentIds
                            body:(nullable NSString *)body
                    contactShare:(nullable OWSContact *)contactShare
                 expireStartedAt:(uint64_t)expireStartedAt
                       expiresAt:(uint64_t)expiresAt
                expiresInSeconds:(unsigned int)expiresInSeconds
                     linkPreview:(nullable OWSLinkPreview *)linkPreview
                  messageSticker:(nullable MessageSticker *)messageSticker
perMessageExpirationDurationSeconds:(unsigned int)perMessageExpirationDurationSeconds
  perMessageExpirationHasExpired:(BOOL)perMessageExpirationHasExpired
       perMessageExpireStartedAt:(uint64_t)perMessageExpireStartedAt
                   quotedMessage:(nullable TSQuotedMessage *)quotedMessage
                   schemaVersion:(NSUInteger)schemaVersion
                   customMessage:(nullable NSString *)customMessage
        infoMessageSchemaVersion:(NSUInteger)infoMessageSchemaVersion
                     messageType:(TSInfoMessageType)messageType
                            read:(BOOL)read
         unregisteredRecipientId:(nullable NSString *)unregisteredRecipientId
                 protocolVersion:(NSUInteger)protocolVersion
                        senderId:(nullable NSString *)senderId
{
    self = [super initWithUniqueId:uniqueId
               receivedAtTimestamp:receivedAtTimestamp
                            sortId:sortId
                         timestamp:timestamp
                    uniqueThreadId:uniqueThreadId
                     attachmentIds:attachmentIds
                              body:body
                      contactShare:contactShare
                   expireStartedAt:expireStartedAt
                         expiresAt:expiresAt
                  expiresInSeconds:expiresInSeconds
                       linkPreview:linkPreview
                    messageSticker:messageSticker
perMessageExpirationDurationSeconds:perMessageExpirationDurationSeconds
    perMessageExpirationHasExpired:perMessageExpirationHasExpired
         perMessageExpireStartedAt:perMessageExpireStartedAt
                     quotedMessage:quotedMessage
                     schemaVersion:schemaVersion
                     customMessage:customMessage
          infoMessageSchemaVersion:infoMessageSchemaVersion
                       messageType:messageType
                              read:read
           unregisteredRecipientId:unregisteredRecipientId];

    if (!self) {
        return self;
    }

    _protocolVersion = protocolVersion;
    _senderId = senderId;

    return self;
}

// clang-format on

// --- CODE GENERATION MARKER

- (NSString *)previewTextWithTransaction:(SDSAnyReadTransaction *)transaction
{
    return [self messageTextWithTransaction:transaction];
}

- (NSString *)messageTextWithTransaction:(SDSAnyReadTransaction *)transaction
{
    if (self.senderId.length < 1) {
        // This was sent from a linked device.
        if (self.isProtocolVersionUnknown) {
            return NSLocalizedString(@"UNKNOWN_PROTOCOL_VERSION_NEED_TO_UPGRADE_FROM_LINKED_DEVICE",
                @"Info message recorded in conversation history when local user receives an "
                @"unknown message from a linked device and needs to "
                @"upgrade.");
        } else {
            return NSLocalizedString(@"UNKNOWN_PROTOCOL_VERSION_UPGRADE_COMPLETE_FROM_LINKED_DEVICE",
                @"Info message recorded in conversation history when local user has "
                @"received an unknown unknown message from a linked device and "
                @"has upgraded.");
        }
    }

    NSString *senderName = nil;
    if (transaction.transitional_yapReadTransaction) {
        senderName =
            [self.contactsManager displayNameForSignalServiceAddress:self.senderId.transitional_signalServiceAddress
                                                         transaction:transaction.transitional_yapReadTransaction];
    }

    if (self.isProtocolVersionUnknown) {
        if (senderName.length > 0) {
            return [NSString
                stringWithFormat:NSLocalizedString(@"UNKNOWN_PROTOCOL_VERSION_NEED_TO_UPGRADE_WITH_NAME_FORMAT",
                                     @"Info message recorded in conversation history when local user receives an "
                                     @"unknown message and needs to "
                                     @"upgrade. Embeds {{user's name or phone number}}."),
                senderName];
        } else {
            OWSFailDebug(@"Missing sender name.");

            return NSLocalizedString(@"UNKNOWN_PROTOCOL_VERSION_NEED_TO_UPGRADE_WITHOUT_NAME",
                @"Info message recorded in conversation history when local user receives an unknown message and needs "
                @"to "
                @"upgrade.");
        }
    } else {
        if (senderName.length > 0) {
            return [NSString
                stringWithFormat:NSLocalizedString(@"UNKNOWN_PROTOCOL_VERSION_UPGRADE_COMPLETE_WITH_NAME_FORMAT",
                                     @"Info message recorded in conversation history when local user has received an "
                                     @"unknown message and has "
                                     @"upgraded. Embeds {{user's name or phone number}}."),
                senderName];
        } else {
            OWSFailDebug(@"Missing sender name.");

            return NSLocalizedString(@"UNKNOWN_PROTOCOL_VERSION_UPGRADE_COMPLETE_WITHOUT_NAME",
                @"Info message recorded in conversation history when local user has received an unknown message and "
                @"has upgraded.");
        }
    }
}

- (BOOL)isProtocolVersionUnknown
{
    return self.protocolVersion > SSKProtos.currentProtocolVersion;
}

@end

NS_ASSUME_NONNULL_END
