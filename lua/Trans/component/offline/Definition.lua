local M = {}

M.component = function (field, max_size)
    if field.definition and field.definition ~= '' then
        local ref = {
            { '英文注释', 'TransRef' }
        }

        local definitions = {
            highlight = 'TransDefinition',
            needformat = true,
            indent = 4,
        }
        local size = 0
        for defin in vim.gsplit(field.definition, '\n', true) do
            if defin ~= '' then
                table.insert(definitions, defin)

                size = size + 1
                if size == max_size then
                    break
                end
            end
        end

        return { ref, definitions }
    end
end

return M

--[[n a formation of people or things one beside another
n a mark that is long relative to its width
n a formation of people or things one behind another
n a length (straight or curved) without breadth or thickness; the trace of a moving point
n text consisting of a row of words written across a page or computer screen
n a single frequency (or very narrow band) of radiation in a spectrum
n a fortified position (especially one marking the most forward position of troops)
n a course of reasoning aimed at demonstrating a truth or falsehood; the methodical process of logical reasoning
n a conductor for transmitting electrical or optical signals or electric power
n a connected series of events or actions or developments
n a spatial location defined by a real or imaginary unidimensional extent
n a slight depression in the smoothness of a surface
n a pipe used to transport liquids or gases
n the road consisting of railroad track and roadbed
n a telephone connection
n acting in conformity
n the descendants of one individual
n something (as a cord or rope) that is long and thin and flexible
n the principal activity in your life that you do to earn money
n in games or sports; a mark indicating positions or bounds of the playing area
n (often plural) a means of communication or access
n a particular kind of product or merchandise
n a commercial organization serving as a common carrier
n space for one line of print (one column wide and 1/14 inch deep) used to measure advertising
n the maximum credit that a customer is allowed
n a succession of notes forming a distinctive sequence
n persuasive but insincere talk that is usually intended to deceive or impress
n a short personal letter
n a conceptual separation or distinction
n mechanical system in a factory whereby an article is conveyed through sites at which successive operations are performed on it
v be in line with; form a line along
v cover the interior of
v make a mark or lines on a surface
v mark with lines
v fill plentifully
v reinforce with fabric
--]]
