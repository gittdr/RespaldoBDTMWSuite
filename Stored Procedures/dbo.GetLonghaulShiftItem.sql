SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create proc [dbo].[GetLonghaulShiftItem] @eqptype varchar(6), @eqpid varchar(13)
as
	-- Proc is obsolete and exists only for compatibility.  Should instead use GetLonghaulShiftItemByStatus or GetLonghaulShiftItemByDate.
	exec GetLonghaulShiftItemByStatus @eqptype, @eqpid
GO
GRANT EXECUTE ON  [dbo].[GetLonghaulShiftItem] TO [public]
GO
