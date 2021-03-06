//------------------------------------------------------------------------------
//
// Copyright (c) 2015 Glympse Inc.  All rights reserved.
//
//------------------------------------------------------------------------------

#ifndef ICARDEVENT_H__GLYMPSE__
#define ICARDEVENT_H__GLYMPSE__

namespace Glympse
{

/**
 * Exposes basic properties of card event
 */
/*O*public**/ struct ICardEvent : public virtual ICommon
{
    /**
     * @return The unique id of this event.
     */
    public: virtual GString getId() = 0;

    /**
     * @return The event type.
     */
    public: virtual GString getType() = 0;

    /**
     * @return The id of the card this event belongs to. The card may not be on the active list any more.
     */
    public: virtual GString getCardId() = 0;

    /** 
     *  @return The member id of the member that triggered this event. They may not be a member of the card anymore.
     */
    public: virtual GString getCardMemberId() = 0;
    
    /**
     *  @return The user id of the Glympse user that triggered this event. They may not be a member of the card anymore.
     */
    public: virtual GString getUserId() = 0;
    
    /**
     * @return The kind of event (native or custom)
     */
    public: virtual GString getKind() = 0;

    /**
     * @return true if the event is an event generated by the glympse platform.
     */
    public: virtual bool isNativeKind() = 0;

    /**
     * @return Map of custom data for this event. null for some events.
     */
    public: virtual GPrimitive getData() = 0;

    /**
     * @return The time that the event was last modified. Epoch ms.
     */
    public: virtual int64 getLastModifiedTime() = 0;

    /**
     * @return The time that the event was created. Epoch ms.
     */
    public: virtual int64 getCreatedTime() = 0;
};

/*C*/typedef O< ICardEvent > GCardEvent;/**/
        
}

#endif // !ICARDEVENT_H__GLYMPSE__
