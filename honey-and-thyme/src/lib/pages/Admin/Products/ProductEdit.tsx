import { useState } from "react";
import type { ProductModel } from "../../../types/api";
import { HoneyButton, HoneyInput } from "../../../components";
import apiClient from "../../../api/client";
import { toast } from "react-toastify";
import { faDollarSign } from "@fortawesome/free-solid-svg-icons";

interface ProductEditProps {
  product: ProductModel;
  onAfterSave: () => void;
  onCancel: () => void;
}

function ProductEdit({
  product: initialProduct,
  onAfterSave,
  onCancel,
}: ProductEditProps) {
  const [isSaving, setIsSaving] = useState(false);
  const [product, setProduct] = useState<ProductModel>(initialProduct);

  const create = apiClient.useMutation("post", "/api/Product/create");
  const update = apiClient.useMutation("post", "/api/Product/update");

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSaving(true);

    try {
      await (product.productId
        ? update.mutateAsync({ body: product })
        : create.mutateAsync({ body: product }));
      onAfterSave();
    } catch (e) {
      toast.error("There was an error saving the product");
      console.error(e);
    } finally {
      setIsSaving(false);
    }
  };
  return (
    <>
      <form onSubmit={handleSave} className="mt-5 space-y-3">
        <HoneyInput
          value={product.name ?? ""}
          onChange={(value) => setProduct((a) => ({ ...a, name: value }))}
          label="Name"
          autoFocus
          required
          type="text"
        />
        <HoneyInput
          value={product.description ?? ""}
          onChange={(value) =>
            setProduct((a) => ({ ...a, description: value }))
          }
          label="Description"
          required
          type="text"
        />
        <HoneyInput
          value={product.price?.toString() ?? ""}
          onChange={(value) =>
            setProduct((a) => ({
              ...a,
              price: Math.round(Number(value) * 100) / 100,
            }))
          }
          label="Price"
          type="number"
          required
          startIcon={faDollarSign}
        />
        <HoneyInput
          value={product.deposit?.toString() ?? ""}
          onChange={(value) =>
            setProduct((a) => ({
              ...a,
              price: Math.round(Number(value) * 100) / 100,
            }))
          }
          label="Deposit"
          type="number"
          required
          startIcon={faDollarSign}
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

export default ProductEdit;
