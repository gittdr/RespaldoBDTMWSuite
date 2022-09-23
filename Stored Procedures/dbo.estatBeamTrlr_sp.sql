SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- 9/5/06: 33827 - trailer beaming  
-- this uses trailer_id
Create procedure [dbo].[estatBeamTrlr_sp] 
	@trailer_id varchar(13), -- beam this	
	@company_id varchar(8)   -- here 
as 
SET NOCOUNT ON

declare @citycode as int

select @citycode = cmp_city from company where cmp_id = @company_id
INSERT INTO expiration ( 
exp_code, 
exp_lastdate, exp_expirationdate, 
exp_routeto, exp_idtype, 
exp_id, -- trailer id
exp_completed, exp_priority, 
exp_compldate, exp_creatdate, 
exp_updateby, 
exp_updateon, exp_city ) 
VALUES (
'INS', 
getdate(), getdate(), 
@company_id, 'TRL', 
@trailer_id,  
'Y', '1', 
getdate(), getdate(), 
'eStat', 
getdate(),
@citycode
)

exec trl_expstatus @trailer_id
GO
GRANT EXECUTE ON  [dbo].[estatBeamTrlr_sp] TO [public]
GO
