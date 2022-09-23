SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.purgetables    Script Date: 6/1/99 11:54:38 AM ******/
create PROC [dbo].[purgetables] @cutoffdays int AS

/*Pass number of days to retain (50 for 50 days)*/

/*Purge MCMESSAGE table */
DELETE FROM MCMESSAGE  
 WHERE MCMESSAGE.MCM_CREATEDATE <= dateadd(dd, -@cutoffdays, getdate())

/*Purge checkcalls */
DELETE FROM checkcall  
 WHERE checkcall.ckc_date <= dateadd(dd, -@cutoffdays, getdate())

return




GO
GRANT EXECUTE ON  [dbo].[purgetables] TO [public]
GO
