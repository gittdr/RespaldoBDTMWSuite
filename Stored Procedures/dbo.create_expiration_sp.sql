SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [dbo].[create_expiration_sp] (
	@duplicatehandler	integer,
	@exp_idtype			char(3),
	@exp_id				varchar(13),
	@exp_code			varchar(6),
	@exp_lastdate		datetime,
	@exp_expirationdate	datetime,
	@exp_completed		char(1),
	@exp_priority		varchar(6),
	@exp_compldate		datetime,
	@exp_description	varchar(100)
	)
AS

/**
 * 
 * NAME:
 * dbo.create_expiration_sp 
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * proc to create expiration
 *
 * RETURNS:
 * NA
 * 
 * RESULT SETS: 
 * NA
 *
 * PARAMETERS:
 * See prototype above
 *
 * REVISION HISTORY:
 * 08/22/2011 PTS58291 - vjh - new proc to create expiration
 */
 
 

		
--  Sample call 
/*
declare @dt datetime
select @dt = GETDATE()
exec create_expiration_sp 2, 'DRV', 'HANS', 'VAC', @dt, @dt, 'N', 1, @dt, 'a sample call to create_expiration_sp'

select * from expiration where exp_idtype='DRV' and exp_id='HANS'
*/

--What to do if one with same code already exists
--1 just insert and don't worry about preexisting records
--2 close all preexisting and create new
--3 close any preexisting with different priority, do nothing is same priority, create new otherwise


DECLARE 
	  @city INT
	, @user varchar(24)
	, @cmpid VARCHAR(8)


DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output


IF @exp_idtype = 'TRC'
	SELECT 	  @city = trc_avl_city
		, @cmpid = trc_avl_cmp_id
	FROM	tractorprofile
	WHERE 	trc_number = @exp_id
ELSE
	select @city=0, @cmpid = 'UNKNOWN'
	
if @duplicatehandler = 2
	UPDATE	expiration
	SET		exp_completed = 'Y',
			exp_updateby = @tmwuser,
			exp_updateon = GETDATE()
	FROM	expiration
	WHERE	expiration.exp_idtype = @exp_idtype AND
			expiration.exp_id = @exp_id AND
			ISNULL(expiration.exp_completed, 'N') = 'N' AND
			expiration.exp_code = @exp_code
if @duplicatehandler = 3
	UPDATE	expiration
	SET		exp_completed = 'Y',
			exp_updateby = @tmwuser,
			exp_updateon = GETDATE()
	FROM	expiration
	WHERE	expiration.exp_idtype = @exp_idtype AND
			expiration.exp_id = @exp_id AND
			ISNULL(expiration.exp_completed, 'N') = 'N' AND
			expiration.exp_code = @exp_code AND
			expiration.exp_priority <> @exp_priority
	
if	@duplicatehandler = 1 
	OR @duplicatehandler = 2
	OR (@duplicatehandler = 3 AND not exists (select 1 from expiration
									WHERE	expiration.exp_idtype = @exp_idtype AND
									expiration.exp_id = @exp_id AND
									ISNULL(expiration.exp_completed, 'N') = 'N' AND
									expiration.exp_code = @exp_code AND
									expiration.exp_priority = @exp_priority))
	INSERT INTO expiration (
		exp_idtype,
		exp_id,
		exp_code,
		exp_lastdate,
		exp_expirationdate,
		exp_routeto,
		exp_completed,
		exp_priority,
		exp_compldate,
		exp_updateby,
		exp_creatdate,
		exp_updateon,
		exp_city,
		exp_description
		)

	VALUES (
		@exp_idtype,
		@exp_id,
		@exp_code,
		ISNULL(@exp_lastdate,GetDate()),
		ISNULL(@exp_expirationdate,GetDate()),
		ISNULL(@cmpid,'UNKNOWN'),
		ISNULL(@exp_completed,'N'),
		ISNULL(@exp_priority,'1'),
		ISNULL(@exp_compldate,'12/31/2049'),
		@tmwuser,
		GetDate(),
		GetDate(),
		ISNULL(@city,0),
		ISNULL(@exp_description,'')
		)


if @exp_idtype = 'TRC' EXEC trc_expstatus @exp_id
if @exp_idtype = 'TRL' EXEC trl_expstatus @exp_id
if @exp_idtype = 'DRV' EXEC drv_expstatus @exp_id
	

GO
GRANT EXECUTE ON  [dbo].[create_expiration_sp] TO [public]
GO
