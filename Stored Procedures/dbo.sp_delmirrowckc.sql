SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE  PROCEDURE [dbo].[sp_delmirrowckc]

as

delete from checkmirrow where 
day(ckh_Date) <  day(getdate())
or
month(ckh_date) <  month(getdate())
GO
