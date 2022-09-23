SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE proc  [dbo].[Tmail_Get_All_Events_For_Stop] (@stopid int)

as

begin

 select evt_eventcode from event where stp_number = @stopid

end
GO
