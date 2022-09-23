SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[d_errlog_forbilling_sp] (@batchid	int)
AS
-- restrieves information from the tts_errorlog for a specified batchid
-- specially set up for billing queue processing
-- DPETE 3/10/11 getting error when the err_mesaage is like 'completed processing order%'

declare @tmpbill table (err_title varchar(254)
,err_message VARCHAR(254)
,errdate varchar(30)
,firstcomma int
,secondcomma int
,err_title_remaining varchar(300)
,ordernbr varchar(15)
,billto varchar(8)
,bookedby varchar(8)
,err_icon char(1)
,err_response varchar(10)
)

DECLARE @int int, @order varchar(15),@billto varchar(8),@bookedby varchar(8)
SELECT  @int = 0
SELECT @order = 'UNKNOWN'
SELECT @billto = 'UNKNOWN'
SELECT @bookedby = 'UNKNOWN'


INSERT INTO @tmpbill
SELECT err_title,err_message,
	convert(varchar,err_date,1) errdate,
	@int firstcomma,
	@int secondcomma,
	err_title err_title_remaining,
	@order ordernbr, @billto billto,
	@bookedby bookedby,
	err_icon , 
	ISNULL(err_response,'') err_response 
FROM tts_errorlog where err_batch = @batchid

UPDATE @tmpbill
SET firstcomma = CHARINDEX(',',err_title)
WHERE CHARINDEX(',',err_title) > 0

UPDATE @tmpbill
SET err_title_remaining = SUBSTRING(err_title,firstcomma + 1,len(err_title) - firstcomma)
WHERE firstcomma > 0

UPDATE @tmpbill
SET secondcomma = CHARINDEX(',',err_title_remaining)
WHERE CHARINDEX(',',err_title_remaining) > 0

UPDATE @tmpbill
SET ordernbr = SUBSTRING(err_title,7,firstcomma - 7 )
WHERE firstcomma > 0
 
UPDATE @tmpbill
SET billto = SUBSTRING(err_title_remaining,9,(secondcomma  - 9))
where secondcomma - 9 > 0 and len (err_title_remaining)  > 9

UPdate  @tmpbill
 set   err_title_remaining = substring(err_title_remaining,secondcomma + 1,len(err_title) - secondcomma)
 WHERE secondcomma > 0 
and len(err_title_remaining) > secondcomma + 1 and (len(err_title) - secondcomma) > 0
 
UPDATE @Tmpbill
SET bookedby = SUBSTRING(err_title_remaining , 10,len(err_title_remaining) - 10)
WHERE secondcomma > 0
and len(err_title_remaining) > 10 
 

SELECT ordernbr , billto ,
bookedby , err_message ,errdate,err_title, err_icon, err_response  
FROM @tmpbill

GO
GRANT EXECUTE ON  [dbo].[d_errlog_forbilling_sp] TO [public]
GO
