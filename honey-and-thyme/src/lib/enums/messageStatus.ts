const MessageStatus = {
  pending: 0,
  sent: 1,
  failed: 2,
} as const;

export type MessageStatus = (typeof MessageStatus)[keyof typeof MessageStatus];

export default MessageStatus;
