//
//  Copyright (c) 2019 Open Whisper Systems. All rights reserved.
//

#import "TSErrorMessage.h"
#import "ContactsManagerProtocol.h"
#import "OWSMessageManager.h"
#import "SSKEnvironment.h"
#import "TSContactThread.h"
#import "TSErrorMessage_privateConstructor.h"
#import <SignalCoreKit/NSDate+OWS.h>
#import <SignalServiceKit/SignalServiceKit-Swift.h>
#import <YapDatabase/YapDatabaseConnection.h>

NS_ASSUME_NONNULL_BEGIN

NSUInteger TSErrorMessageSchemaVersion = 1;

@interface TSErrorMessage ()

@property (nonatomic, getter=wasRead) BOOL read;

@property (nonatomic, readonly) NSUInteger errorMessageSchemaVersion;

@end

#pragma mark -

@implementation TSErrorMessage

- (nullable instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (!self) {
        return self;
    }

    if (self.errorMessageSchemaVersion < 1) {
        _read = YES;
    }

    _errorMessageSchemaVersion = TSErrorMessageSchemaVersion;

    if (self.isDynamicInteraction) {
        self.read = YES;
    }

    return self;
}

- (instancetype)initWithTimestamp:(uint64_t)timestamp
                         inThread:(nullable TSThread *)thread
                failedMessageType:(TSErrorMessageType)errorMessageType
                      recipientId:(nullable NSString *)recipientId
{
    self = [super initMessageWithTimestamp:timestamp
                                   inThread:thread
                                messageBody:nil
                              attachmentIds:@[]
                           expiresInSeconds:0
                            expireStartedAt:0
                              quotedMessage:nil
                               contactShare:nil
                                linkPreview:nil
                             messageSticker:nil
        perMessageExpirationDurationSeconds:0];

    if (!self) {
        return self;
    }

    _errorType = errorMessageType;
    _recipientId = recipientId;
    _errorMessageSchemaVersion = TSErrorMessageSchemaVersion;

    if (self.isDynamicInteraction) {
        self.read = YES;
    }

    return self;
}

- (instancetype)initWithTimestamp:(uint64_t)timestamp
                         inThread:(nullable TSThread *)thread
                failedMessageType:(TSErrorMessageType)errorMessageType
{
    return [self initWithTimestamp:timestamp inThread:thread failedMessageType:errorMessageType recipientId:nil];
}

- (instancetype)initWithEnvelope:(SSKProtoEnvelope *)envelope
                 withTransaction:(YapDatabaseReadWriteTransaction *)transaction
               failedMessageType:(TSErrorMessageType)errorMessageType
{
    TSContactThread *contactThread = [TSContactThread getOrCreateThreadWithContactId:envelope.sourceE164
                                                                         transaction:transaction];

    // Legit usage of senderTimestamp. We don't actually currently surface it in the UI, but it serves as
    // a reference to the envelope which we failed to process.
    return [self initWithTimestamp:envelope.timestamp inThread:contactThread failedMessageType:errorMessageType];
}

// --- CODE GENERATION MARKER

// This snippet is generated by /Scripts/sds_codegen/sds_generate.py. Do not manually edit it, instead run `sds_codegen.sh`.

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
       errorMessageSchemaVersion:(NSUInteger)errorMessageSchemaVersion
                       errorType:(TSErrorMessageType)errorType
                            read:(BOOL)read
                     recipientId:(nullable NSString *)recipientId
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
                     schemaVersion:schemaVersion];

    if (!self) {
        return self;
    }

    _errorMessageSchemaVersion = errorMessageSchemaVersion;
    _errorType = errorType;
    _read = read;
    _recipientId = recipientId;

    return self;
}

// clang-format on

// --- CODE GENERATION MARKER

- (OWSInteractionType)interactionType
{
    return OWSInteractionType_Error;
}

- (NSString *)previewTextWithTransaction:(SDSAnyReadTransaction *)transaction
{
    switch (_errorType) {
        case TSErrorMessageNoSession:
            return NSLocalizedString(@"ERROR_MESSAGE_NO_SESSION", @"");
        case TSErrorMessageInvalidMessage:
            return NSLocalizedString(@"ERROR_MESSAGE_INVALID_MESSAGE", @"");
        case TSErrorMessageInvalidVersion:
            return NSLocalizedString(@"ERROR_MESSAGE_INVALID_VERSION", @"");
        case TSErrorMessageDuplicateMessage:
            return NSLocalizedString(@"ERROR_MESSAGE_DUPLICATE_MESSAGE", @"");
        case TSErrorMessageInvalidKeyException:
            return NSLocalizedString(@"ERROR_MESSAGE_INVALID_KEY_EXCEPTION", @"");
        case TSErrorMessageWrongTrustedIdentityKey:
            return NSLocalizedString(@"ERROR_MESSAGE_WRONG_TRUSTED_IDENTITY_KEY", @"");
        case TSErrorMessageNonBlockingIdentityChange: {
            if (self.recipientId) {
                if (transaction.transitional_yapReadTransaction) {
                    NSString *messageFormat = NSLocalizedString(@"ERROR_MESSAGE_NON_BLOCKING_IDENTITY_CHANGE_FORMAT",
                        @"Shown when signal users safety numbers changed, embeds the user's {{name or phone number}}");

                    NSString *recipientDisplayName = [SSKEnvironment.shared.contactsManager
                        displayNameForSignalServiceAddress:self.recipientId.transitional_signalServiceAddress
                                               transaction:transaction.transitional_yapReadTransaction];
                    return [NSString stringWithFormat:messageFormat, recipientDisplayName];
                }
            } else {
                // recipientId will be nil for legacy errors
                return NSLocalizedString(
                    @"ERROR_MESSAGE_NON_BLOCKING_IDENTITY_CHANGE", @"Shown when signal users safety numbers changed");
            }
        }
        case TSErrorMessageUnknownContactBlockOffer:
            return NSLocalizedString(@"UNKNOWN_CONTACT_BLOCK_OFFER",
                @"Message shown in conversation view that offers to block an unknown user.");
        case TSErrorMessageGroupCreationFailed:
            return NSLocalizedString(@"GROUP_CREATION_FAILED",
                @"Message shown in conversation view that indicates there were issues with group creation.");
        default:
            OWSFailDebug(@"failure: unknown error type");
            break;
    }
    return NSLocalizedString(@"ERROR_MESSAGE_UNKNOWN_ERROR", @"");
}

+ (instancetype)corruptedMessageWithEnvelope:(SSKProtoEnvelope *)envelope
                             withTransaction:(YapDatabaseReadWriteTransaction *)transaction
{
    return [[self alloc] initWithEnvelope:envelope
                          withTransaction:transaction
                        failedMessageType:TSErrorMessageInvalidMessage];
}

+ (instancetype)corruptedMessageInUnknownThread
{
    // MJK TODO - Seems like we could safely remove this timestamp
    return [[self alloc] initWithTimestamp:[NSDate ows_millisecondTimeStamp]
                                  inThread:nil
                         failedMessageType:TSErrorMessageInvalidMessage];
}

+ (instancetype)invalidVersionWithEnvelope:(SSKProtoEnvelope *)envelope
                           withTransaction:(YapDatabaseReadWriteTransaction *)transaction
{
    return [[self alloc] initWithEnvelope:envelope
                          withTransaction:transaction
                        failedMessageType:TSErrorMessageInvalidVersion];
}

+ (instancetype)invalidKeyExceptionWithEnvelope:(SSKProtoEnvelope *)envelope
                                withTransaction:(YapDatabaseReadWriteTransaction *)transaction
{
    return [[self alloc] initWithEnvelope:envelope
                          withTransaction:transaction
                        failedMessageType:TSErrorMessageInvalidKeyException];
}

+ (instancetype)missingSessionWithEnvelope:(SSKProtoEnvelope *)envelope
                           withTransaction:(YapDatabaseReadWriteTransaction *)transaction
{
    return
        [[self alloc] initWithEnvelope:envelope withTransaction:transaction failedMessageType:TSErrorMessageNoSession];
}

+ (instancetype)nonblockingIdentityChangeInThread:(TSThread *)thread recipientId:(NSString *)recipientId
{
    // MJK TODO - should be safe to remove this senderTimestamp
    return [[self alloc] initWithTimestamp:[NSDate ows_millisecondTimeStamp]
                                  inThread:thread
                         failedMessageType:TSErrorMessageNonBlockingIdentityChange
                               recipientId:recipientId];
}

#pragma mark - OWSReadTracking

- (uint64_t)expireStartedAt
{
    return 0;
}

- (BOOL)shouldAffectUnreadCounts
{
    return NO;
}

- (void)markAsReadAtTimestamp:(uint64_t)readTimestamp
              sendReadReceipt:(BOOL)sendReadReceipt
                  transaction:(YapDatabaseReadWriteTransaction *)transaction
{
    OWSAssertDebug(transaction);

    if (_read) {
        return;
    }

    OWSLogDebug(@"marking as read uniqueId: %@ which has timestamp: %llu", self.uniqueId, self.timestamp);
    _read = YES;
    [self saveWithTransaction:transaction];

    // Ignore sendReadReceipt - it doesn't apply to error messages.
}

@end

NS_ASSUME_NONNULL_END
