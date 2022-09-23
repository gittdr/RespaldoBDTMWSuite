SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Part 3

CREATE PROCEDURE [dbo].[dwPushDBTimestamp]
	(
		@NowTimestamp varbinary(16) OUTPUT 
	)
AS

declare @XType varchar(10)

select @XType = T2.XTYPE
from sysobjects T1 inner join syscolumns T2 on T1.id = T2.id
where T1.xtype = 'U'
AND T1.name = 'dwHeartbeat'
AND T2.name = 'RowVersionValue'

If @XType = '189' 
begin
	set @NowTimestamp = (select @@DBTS)
end
Else 
begin
	set @NowTimestamp = (select RowVersionValue from dwHeartbeat with (NOLOCK))
end

GO
GRANT EXECUTE ON  [dbo].[dwPushDBTimestamp] TO [public]
GO
