#encoding: utf-8
class Teacher::StructuresController < Teacher::ApplicationController

  # ajax
  def show
    structure = Structure.where(id: params[:id]).first
    if structure.type == "book"
      tree = structure.structure_tree
      render_json({ tree: tree, root_folder_id: structure.id.to_s }) and return
    else
      books = structure.children.asc(:created_at)
      books_data = books.each_with_index.map do |b, i|
        {
          selected: (i == 0).to_s,
          book_id: b.id.to_s,
          book_name: b.name
        }
      end
      tree = books.first.structure_tree
      render_json({ tree: tree, root_folder_id: books.first.id.to_s, books: books_data }) and return
    end
  end
end
