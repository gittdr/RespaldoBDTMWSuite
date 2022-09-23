SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


--select top 5000 * from vTTSTMW_TMWLGHLeg

CREATE View [dbo].[vTTSTMW_TMWLGHLeg]

As
Select (select mpp_id from manpowerprofile WITH (NOLOCK) where lgh_driver1 =
mpp_id) as [Driver ID],
        (select trc_number from tractorprofile WITH (NOLOCK) where trc_number
= lgh_tractor) as [Tractor],
       IsNull((select orderheader.ord_hdrnumber from orderheader WITH (NOLOCK) where
orderheader.ord_hdrnumber = legheader.ord_hdrnumber),legheader.ord_hdrnumber) as
[OrderHeaderNumber],
       legheader.lgh_number,
	   legheader.mov_number
     




From
     legheader WITH (NOLOCK) Left Join MR_FakeJoin On legheader.lgh_number = MR_FakeJoin.field1

--Where stmlsleg_lghnumber = legheader.lgh_number


--Grant Select on vTTSTMW_TMWLGHLeg to public

GO
GRANT DELETE ON  [dbo].[vTTSTMW_TMWLGHLeg] TO [public]
GO
GRANT INSERT ON  [dbo].[vTTSTMW_TMWLGHLeg] TO [public]
GO
GRANT REFERENCES ON  [dbo].[vTTSTMW_TMWLGHLeg] TO [public]
GO
GRANT SELECT ON  [dbo].[vTTSTMW_TMWLGHLeg] TO [public]
GO
GRANT UPDATE ON  [dbo].[vTTSTMW_TMWLGHLeg] TO [public]
GO
