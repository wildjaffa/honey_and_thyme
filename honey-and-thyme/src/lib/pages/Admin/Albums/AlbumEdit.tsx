import { useState } from "react";
import type { AlbumModel } from "../../../types/api";
import { HoneyButton, HoneyCheckbox, HoneyInput } from "../../../components";
import apiClient from "../../../api/client";
import { toast } from "react-toastify";

interface AlbumEditProps {
  album: AlbumModel;
  onAfterSave: () => void;
  onCancel: () => void;
}

function AlbumEdit({
  album: initialAlbum,
  onAfterSave,
  onCancel,
}: AlbumEditProps) {
  const [isSaving, setIsSaving] = useState(false);
  const [album, setAlbum] = useState<AlbumModel>(initialAlbum);

  const create = apiClient.useMutation("post", "/albums/create");
  const update = apiClient.useMutation("post", "/albums/update");

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSaving(true);

    try {
      await (album.albumId
        ? update.mutateAsync({ body: album })
        : create.mutateAsync({ body: album }));
      onAfterSave();
    } catch (e) {
      toast.error("There was an error saving the album");
      console.error(e);
    } finally {
      setIsSaving(false);
    }
  };
  return (
    <>
      <form onSubmit={handleSave} className="mt-5 space-y-3">
        <HoneyInput
          value={album.name ?? ""}
          onChange={(value) => setAlbum((a) => ({ ...a, name: value }))}
          label="Name"
          autoFocus
          required
          type="text"
        />
        <HoneyInput
          value={album.description ?? ""}
          onChange={(value) => setAlbum((a) => ({ ...a, description: value }))}
          label="Description"
          required
          type="text"
        />
        <HoneyInput
          value={album.password ?? ""}
          onChange={(value) => setAlbum((a) => ({ ...a, password: value }))}
          label="Password (optional)"
          type="text"
        />
        <HoneyCheckbox
          checked={album.isPublic === true}
          onChange={(value) => setAlbum((a) => ({ ...a, isPublic: value }))}
          label="Is Public?"
        />
        <div className="flex gap-2">
          <HoneyButton isSubmit isLoading={isSaving}>
            Save
          </HoneyButton>
          <HoneyButton onClick={onCancel}>Cancel</HoneyButton>
        </div>
      </form>
    </>
  );
}

export default AlbumEdit;
