SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create function [dbo].[CheckAsgnID_r](@AssignType varchar(6), @AssignID varchar(13), @allowCAR int=0, @AllowTrl2 int = 0, @Allow3rd int=0, @AllowUser int=0, @AllowExternal int=0) returns int
as
begin
-- There are actually two varieties of the CheckAsgnID function, CheckAsgnID_r (the one that really does the work), and CheckAsgnID (the one that appears
-- everywhere).  The reason for this is that you cannot modify a function that is used within a constraint.  CheckAsgnID will be used in many
-- constraints.  In case we need to modify its behavior at some point in the future it just relays its calls to CheckAsgnID_r.  Because CheckAsgnID_r is 
-- not used within any constraints, it can be modified.
if (@AssignType = 'DRV' and exists (select * from manpowerprofile where mpp_id = @AssignID)) return 1
if (@AssignType = 'TRC' and exists (select * from tractorprofile where trc_number = @AssignID)) return 1
if (@AssignType = 'TRL' and exists (select * from trailerprofile where trl_id = @AssignID)) return 1
if (@AllowCAR <> 0 and @AssignType = 'CAR' and exists (select * from carrierprofile where car_id = @AssignID)) return 1
if (@AllowTrl2 <> 0 and @AssignType = 'CHA' and exists (select * from trailerprofile where trl_id = @AssignID)) return 1
if (@AllowTrl2 <> 0 and @AssignType = 'DOL' and exists (select * from trailerprofile where trl_id = @AssignID)) return 1
if (@Allow3rd <> 0 and @AssignType = 'TPR' and exists (select * from thirdpartyprofile where tpr_id = @AssignID)) return 1
if (@AllowUser <> 0 and @AssignType = 'USER' and exists (select * from ttsusers where usr_userid = @AssignID)) return 1
if (@AllowExternal <>0 AND @AssignType = 'EXTERN') return 1
return 0
end
GO
