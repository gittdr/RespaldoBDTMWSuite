SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[make_expiration] 
	  @asgn_type CHAR(3)
	, @asgn_id VARCHAR(13)
	, @exp_code VARCHAR(6)
AS

DECLARE 
	  @city INT
	, @user varchar(24)
	, @cmpid VARCHAR(8)

--PTS 23691 CGK 9/3/2004
DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output

IF @asgn_type = 'TRC'
	SELECT 	  @city = trc_avl_city
		, @cmpid = trc_avl_cmp_id
	FROM	tractorprofile
	WHERE 	trc_number = @asgn_id
ELSE
	RETURN

SELECT @user = @tmwuser

INSERT INTO expiration (
	  exp_idtype
	, exp_id
	, exp_code
	, exp_lastdate
	, exp_expirationdate
	, exp_routeto
	, exp_completed
	, exp_priority
	, exp_compldate
	, exp_updateby
	, exp_creatdate
	, exp_updateon
	, exp_city )
VALUES (
	  @asgn_type
	, @asgn_id
	, @exp_code
	, GetDate()
	, GetDate()
	, @cmpid
	, 'N'
	, '1'
	, '12/31/2049'
	, @user
	, GetDate()
	, GetDate()
	, @city )

EXEC trc_expstatus @asgn_id
	
GO
GRANT EXECUTE ON  [dbo].[make_expiration] TO [public]
GO
