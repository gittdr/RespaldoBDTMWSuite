SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create function [dbo].[CheckLabel_r](@value varchar(6), @labeldef varchar(20), @allownull int=1) returns int
as
begin
-- There are actually two varieties of the CheckLabel function, CheckLabel_r (the one that really does the work), and CheckLabel (the one that appears
-- everywhere).  The reason for this is that you cannot modify a function that is used within a constraint.  CheckLabel will be used in many
-- constraints.  In case we need to modify its behavior at some point in the future it just relays its calls to CheckLabel_r.  Because CheckLabel_r is
-- not used within any constraints, it can be modified.
-- Note that a non-zero @allowNull parameter actually allows both blank and NULL.
if (isnull(@value, '') = '')
begin
if isnull(@allownull, 1)<>0 return 1
end
else
begin
if exists (select * from labelfile where labeldefinition = @labeldef and abbr = @value) return 1
end
return 0
end
GO
