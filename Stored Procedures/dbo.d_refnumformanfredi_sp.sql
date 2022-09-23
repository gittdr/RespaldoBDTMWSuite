SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE procedure [dbo].[d_refnumformanfredi_sp]
		@id int,
	        @type int,
                @ref_table varchar(18)


as

if @type = 1 begin
SELECT     top 4 max(referencenumber.ref_number) ref_number,
           labelfile.name,
	   min(ref_sequence) ref_sequence,
           'REFERENCE' ref_text
FROM       referencenumber ,
           labelfile     
WHERE      ( referencenumber.ref_type = labelfile.abbr ) and          
			  ( ( referencenumber.ref_table = @ref_table ) and          
			  ( referencenumber.ref_tablekey = @id ) and          
			  ( labelfile.labeldefinition = 'ReferenceNumbers' ) AND
			  ( referencenumber.ref_type not in ('BL#','HEE') )) 
group by   labelfile.name
order by   ref_sequence 

end else begin
SELECT     top 4 max(referencenumber.ref_number) ref_number,
           labelfile.name,
	   max(ref_sequence) ref_sequence 
into       #temp1    
FROM       referencenumber ,
           labelfile     
WHERE      ( referencenumber.ref_type = labelfile.abbr ) and          
			  ( ( referencenumber.ref_table = @ref_table ) and          
			  ( referencenumber.ref_tablekey = @id ) and          
			  ( labelfile.labeldefinition = 'ReferenceNumbers' ) AND
			  ( referencenumber.ref_type not in ('BL#','HEE') ))
group by   labelfile.name
order by   ref_sequence 

SELECT     top 4 max(referencenumber.ref_number) ref_number,
           labelfile.name,
	   min(ref_sequence) ref_sequence,
           '' ref_text 
FROM       referencenumber ,
           labelfile     
WHERE      ( referencenumber.ref_type = labelfile.abbr ) and          
			  ( ( referencenumber.ref_table = @ref_table ) and          
			  ( referencenumber.ref_tablekey = @id ) and          
			  ( labelfile.labeldefinition = 'ReferenceNumbers' ) AND
			  ( referencenumber.ref_type not in ('BL#','HEE') )) and
			    ref_sequence > (select max( ref_sequence)from
					   #temp1 )
group by   labelfile.name
order by   ref_sequence 
END

GO
GRANT EXECUTE ON  [dbo].[d_refnumformanfredi_sp] TO [public]
GO
